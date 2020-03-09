//
//  NSRunLoop+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 30.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _XOPEN_SOURCE 700

#import "import-private.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/private/NSRunLoop-Private.h>
#import "NSDate+Posix-Private.h"

// std-c and dependencies
#include <unistd.h>
#include <sys/select.h>


#include <sys/select.h>


// storage for select flag sets, and the file handles that are
// waiting for this mode.
// TODO: add timers
//
struct posix_mode
{
   fd_set   _readSet;

   int    _n_handles;
   int    _s_handles;
   int    *_handles;
   int    _handle_space[ 12];

   // this is used to reuse the _readSet if possible
   long   _set_generation;
   long   _generation;
};


static inline void   posix_mode_init( struct posix_mode *ctxt)
{
   FD_ZERO( &ctxt->_readSet);
   ctxt->_s_handles      = 12;
   ctxt->_handles        = ctxt->_handle_space;
   ctxt->_n_handles      = 0;
   ctxt->_set_generation = -1;
   ctxt->_generation     = 0;
}


static inline void   posix_mode_done( struct posix_mode *ctxt)
{
   if( ctxt->_handles != ctxt->_handle_space)
      mulle_free( ctxt->_handles);

   ctxt->_handles   = NULL;
   ctxt->_s_handles = 0;
}



static inline int   posix_mode_is_full( struct posix_mode *ctxt)
{
   return( ctxt->_n_handles >= ctxt->_s_handles);
}


static inline void   posix_mode_grow( struct posix_mode *ctxt)
{
   void   *buf;

   ctxt->_s_handles += ctxt->_s_handles;

   buf = mulle_malloc( ctxt->_s_handles * sizeof( int));
   memcpy( buf, ctxt->_handles, ctxt->_n_handles * sizeof( int));

   ctxt->_handles = buf;
}


static int   compare_fds( const void *a_p, const void *b_p)
{
   int   a;
   int   b;

   a = *(int *) a_p;
   b = *(int *) b_p;
   return( a - b);
}


static inline void   posix_mode_add_handle( struct posix_mode *ctxt, int fd)
{
   assert( fd >= 0);

   if( posix_mode_is_full( ctxt))
      posix_mode_grow( ctxt);

   ctxt->_handles[ ctxt->_n_handles++] = fd;
   qsort( ctxt->_handles, ctxt->_n_handles, sizeof( int), compare_fds);
   ctxt->_generation++;
}


static inline int   posix_mode_get_maxhandle( struct posix_mode *ctxt)
{
   if( ctxt->_n_handles)
      return( ctxt->_handles[ ctxt->_n_handles - 1]);
   return( -1);
}


static inline int   posix_mode_find_handle( struct posix_mode *ctxt, int fd)
{
   int    *fd_p;
   int    *fd_sentinel;

   assert( fd >= 0);

   fd_p        = ctxt->_handles;
   fd_sentinel = &fd_p[ ctxt->_n_handles];
   while( fd_p < fd_sentinel)
   {
      if( *fd_p == fd)
         return( (int) (fd_p - ctxt->_handles));
      ++fd_p;
   }
   return( -1);
}


static inline void   posix_mode_remove_handle( struct posix_mode *ctxt, int fd)
{
   int  i;

   i = posix_mode_find_handle( ctxt, fd);
   if( i == -1)
      return;

   ctxt->_handles[ i] = INT_MAX;
   --ctxt->_n_handles;

   qsort( ctxt->_handles, ctxt->_n_handles, sizeof( int), compare_fds);
   ctxt->_generation++;
}


static inline void   posix_mode_set_fdset_handles( struct posix_mode *ctxt,
                                                   fd_set   *set)
{
   int  *p;
   int  *sentinel;
   int  fd;

   assert( ctxt);

   if( ctxt->_generation == ctxt->_set_generation)
      return;
   ctxt->_set_generation = ctxt->_generation;

   p        = ctxt->_handles;
   sentinel = &p[ ctxt->_n_handles];
   while( p < sentinel)
   {
      fd = *p++;
      FD_SET( fd, set);
   }
}


@implementation NSRunLoop (Posix)

- (void) _finalizePosix:(struct posix_mode *) ctxt
{
   struct mulle_allocator   *allocator;

   allocator = MulleObjCInstanceGetAllocator( self);
   posix_mode_done( ctxt);
   mulle_allocator_free( allocator, ctxt);
}


static inline struct posix_mode  *
   getOrCreatePosixMode( NSRunLoop *self, struct MulleRunLoopMode *mode)
{
   struct posix_mode        *ctxt;
   struct mulle_allocator   *allocator;

   ctxt = (struct posix_mode *) mode->osspecific;
   if( ! ctxt)
   {
      allocator                = MulleObjCInstanceGetAllocator( self);
      ctxt                     = mulle_allocator_malloc( allocator,
                                                         sizeof( struct posix_mode));
      posix_mode_init( ctxt);
      mode->osspecific         = ctxt;
      mode->osspecificFinalize = @selector( _finalizePosix:);
   }
   return( ctxt);
}


- (void) _notifyFileHandles:(struct posix_mode *) ctxt
                        max:(int) max
{
   int                           *fd_p;
   int                           *fd_sentinel;
   int                           fd;
   NSObject< _NSFileDescriptor>  *fileHandle;

   // timeout
   [_readyHandles removeAllObjects];

   fd_p        = ctxt->_handles;
   fd_sentinel = &fd_p[ max];
   while( fd_p < fd_sentinel)
   {
      fd = *fd_p++;
      if( FD_ISSET( fd, &ctxt->_readSet))
      {
         FD_CLR( fd, &ctxt->_readSet);

         fileHandle = NSMapGet( _fileHandleTable, (void *) (intptr_t) fd);
         [_readyHandles addObject:fileHandle];
      }
   }

   [_readyHandles makeObjectsPerformSelector:@selector(_notifyWithRunLoop:)
                                  withObject:self];
}


- (enum MulleRunLoopInputState) _acceptInputForRunLoopMode:(struct MulleRunLoopMode *) mode
                                                beforeDate:(NSDate *) date
{
   int                           rval;
   int                           max;
   NSTimeInterval                now;
   NSTimer                       *firstTimer;
   static struct timeval         poll_once;
   struct posix_mode             *ctxt;
   struct timeval                timeout;
   struct timeval                firetime;

   // consider them consumed afterwards
   [self _sendMessagesOfRunLoopMode:mode];

   // because we mix timers inbetween we have to loop to here again
   //fprintf( stderr, "preloop\n");
loop:
   //fprintf( stderr, "loop\n");
   // now fire all the timers that we have
   now  = [NSDate timeIntervalSinceReferenceDate];
   [self _fireTimersOfRunLoopMode:mode
                     timeInterval:now];

   ctxt = getOrCreatePosixMode( self, mode);

   posix_mode_set_fdset_handles( ctxt, &ctxt->_readSet);
   max = posix_mode_get_maxhandle( ctxt);

// we want to wait for timers, so exiting immediately here is not a
// good idea (except if we have no timers)
posix_recalc:
   firstTimer = nil;
   timeout    = poll_once;
   //fprintf( stderr, "posix_recalc at %.3f\n", [NSDate timeIntervalSinceReferenceDate]);

   if( date)
   {
      timeout = [date _timevalForSelect];
      //fprintf( stderr, "input timeout: %lds.%06ldus\n", (long) timeout.tv_sec, (long) timeout.tv_usec);

      firstTimer = [self _firstTimerToFireOfRunLoopMode:mode];
      if( firstTimer)
      {
         firetime = [[firstTimer fireDate] _timevalForSelect];
         if( firetime.tv_sec < timeout.tv_sec ||
             (firetime.tv_sec == timeout.tv_sec && firetime.tv_usec < timeout.tv_usec))
         {
            //fprintf( stderr, "firetime: %lds.%06ldus\n", (long) firetime.tv_sec, (long) firetime.tv_usec);
            timeout = firetime;
         }
         else
         {
            //fprintf( stderr, "no timer of interest\n");
            firstTimer = nil;    // no timer to fire while we wait
         }
      }
      else
      {
         //fprintf( stderr, "no timer at all\n");
         if( max < 0)      // no timer or input to serve ? then return
            return( MulleRunLoopNoTimersOrInputLeft);
      }
   }


   //
   // though this looks like a loop, ideally it will run just once
   //
   for(;;)
   {
      //
      // don't let timers or so run here, because we want to keep the
      // _readSet stable in case of EINTR (assumed to be very rare)
      //
      //fprintf( stderr, "timeout: %lds.%06ldus\n", (long) timeout.tv_sec, (long) timeout.tv_usec);

      rval = select( max + 1, &ctxt->_readSet, NULL, NULL, &timeout);
      if( rval == -1)
      {
         if( errno == EINTR)
         {
            //fprintf( stderr, "retry:  %lds.%06ldus\n", (long) timeout.tv_sec, (long) timeout.tv_usec);
#ifdef __linux__
         // linux modifies timout, but other OS don't (supposedly)
            continue;
#else
            goto posix_recalc;
#endif
         }
         if( errno == ENOMEM)
         {
            // mulle_allocator_raise();
         }
         abort();
      }

      break;
   }

   if( rval == 0)
   {
      //
      // timeout: if we had a timer, our timeout has been cut short
      //          we need to fire timers, and then do another select
      //          to complete the wait for input
      //
      if( firstTimer)
      {
         //fprintf( stderr, "wait for timer\n");
         goto loop;
      }

      return( MulleRunLoopTimeout);
   }

   [self _notifyFileHandles:ctxt
                        max:rval];
   return( MulleRunLoopInputReceived);
}

@end

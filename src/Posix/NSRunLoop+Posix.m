//
//  NSRunLoop+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 30.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _XOPEN_SOURCE 700

#import "dependencies.h"

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

   int      _n_handles;
   int      _s_handles;
   int      *_handles;
   int      _handle_space[ 12];
};

static inline void   posix_mode_init( struct posix_mode *ctxt)
{
   FD_ZERO( &ctxt->_readSet);
   ctxt->_s_handles = 12;
   ctxt->_handles   = ctxt->_handle_space;
   ctxt->_n_handles = 0;
}


static inline void   posix_mode_done( struct posix_mode *ctxt)
{
   if( ctxt->_handles != ctxt->_handle_space)
      mulle_free( ctxt->_handles);

   ctxt->_handles   = NULL;
   ctxt->_s_handles = 0;
}


static void  posix_mode_free_callback( struct mulle_container_valuecallback *callback,
      void *p,
      struct mulle_allocator *allocator)
{
   posix_mode_done( p);
   mulle_allocator_free( allocator, p);
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
}


static inline void   posix_mode_set_fdset_handles( struct posix_mode *ctxt,
                                                               fd_set   *set)
{
   int  *p;
   int  *sentinel;
   int  fd;

   assert( ctxt);

   p        = ctxt->_handles;
   sentinel = &p[ ctxt->_n_handles];
   while( p < sentinel)
   {
      fd = *p++;
      FD_SET( fd, set);
   }
}


@implementation NSRunLoop (Posix)

static struct posix_mode  *getOrCreatePosixMode( NSRunLoop *self, NSString *mode)
{
   struct posix_mode   *ctxt;

   ctxt = (struct posix_mode *) NSMapGet( self->_modeTable, mode);
   if( ! ctxt)
   {
      // will be releases by NSMap
      ctxt = mulle_calloc( 1, sizeof( struct posix_mode));
      NSMapInsertKnownAbsent( self->_modeTable, mode, ctxt);
      _NSObjCMapTableSetValueRelease( self->_modeTable, posix_mode_free_callback);
   }
   return( ctxt);
}


- (void) _acceptInputForMode:(NSString *) mode
                  beforeDate:(NSDate *) date
{
   static struct timeval   poll_once;
   struct timeval          waitingtime;
   struct timeval          *timeout;
   int                     fd;
   int                     i;
   int                     max;
   int                     *fd_p, *fd_sentinel;
   int                     rval;
   NSObject< _NSFileDescriptor>  *fileHandle;
   struct posix_mode       *ctxt;

   ctxt = getOrCreatePosixMode( self, mode);

   posix_mode_set_fdset_handles( ctxt, &ctxt->_readSet);
   max = posix_mode_get_maxhandle( ctxt);

   timeout = &poll_once;
   if( date)
   {
      waitingtime = [date _timevalForSelect];
      timeout     = &waitingtime;
   }

   for(;;)
   {
      rval = select( max + 1, &ctxt->_readSet, NULL, NULL, timeout);
      if( rval == -1 && errno == EINTR)
         continue;
      break;
   }

   // timeout
   i   = 0;
   max = rval;

   // superflous reentrance check
   NSParameterAssert( [_readyHandles count] == 0);

   fd_p        = ctxt->_handles;
   fd_sentinel = &fd_p[ max];
   while( fd_p < fd_sentinel)
   {
      fd = *fd_p++;
      if( FD_ISSET( fd, &ctxt->_readSet))
      {
         FD_CLR( fd, &ctxt->_readSet);

         fileHandle = NSMapGet( _fileHandleTable, (void *) fd);
         [_readyHandles addObject:fileHandle];
      }
   }

   for( fileHandle in _readyHandles)
      [fileHandle _notifyWithRunLoop:self];

   [_readyHandles removeAllObjects];
}

@end

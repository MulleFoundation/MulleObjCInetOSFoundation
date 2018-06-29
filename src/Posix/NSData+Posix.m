//
//  NSData+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "dependencies.h"


#import <MulleObjCOSBaseFoundation/private/NSPageAllocation-Private.h>

// std-c and dependencies
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>


@implementation NSData( Posix)


// could be anywhere
+ (void) load
{
   _MulleObjCSetPageSize( sysconf(_SC_PAGESIZE));
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   char                     *buf;
   char                     *filename;
   int                      fd;
   ssize_t                  actual_len;
   ssize_t                  len;
   struct mulle_allocator   *allocator;
   struct stat              info;

   filename = [path fileSystemRepresentation];
   fd = open( filename, O_RDONLY);
   if( fd == -1)
   {
      [self release];
      return( nil);
   }

   buf = NULL;
   //
   // the length we get here is "our" length
   // or more, for simplicity we don't read more
   // than info.st_size
   //
   if( fstat( fd, &info) != -1)
   {
      if( ! (info.st_mode & S_IFDIR))
      {
         // warning this may have a 2 GB problem is off_t is 64 bit
         // and ssize_t is 32 bit

         len = (size_t) info.st_size;
         if( (off_t) len == info.st_size)
         {
            allocator = MulleObjCObjectGetAllocator( self);

            buf = mulle_allocator_malloc( allocator, len);
            if( buf)
            {
               // The system guarantees to read the number of bytes requested
               // if the descriptor references a normal file that has that
               // many bytes left before the end-of-file, but in no other case

               actual_len = read( fd, buf, len);
               if( actual_len != -1)
               {
                  if( actual_len != len)
                     buf = mulle_allocator_realloc( allocator, buf, actual_len);
               }
            }
         }
         else
            errno = EFBIG;
      }
   }
   close( fd);

   if( ! buf)
   {
      [self release];
      return( nil);
   }

   return( [self initWithBytesNoCopy:buf
                              length:actual_len
                           allocator:allocator]);
}


- (instancetype) initWithContentsOfMappedFile:(NSString *) path
{
   return( [self initWithContentsOfFile:path]);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSString  *new_path;
   ssize_t   len;
   int       fd;
   int       rval;
   char      *c_path;
   char      *c_new;
   char      *c_old;

   NSParameterAssert( [path length]);

   new_path = flag ? [path stringByAppendingString:@"~"] : path;
   c_path   = [new_path fileSystemRepresentation];

   fd = open( c_path, O_WRONLY|O_CREAT|O_TRUNC, 0666 );
   if( fd == -1)
      return( NO);

   len = [self length];
   if( write( fd, [self bytes], len) != len)
   {
      close( fd);
      return( NO);
   }
   close( fd);

   if( ! flag)
      return( YES);

   c_new = [path fileSystemRepresentation];
   c_old = c_path;

   rval = unlink( c_new);
   if( rval)
   {
      if( errno != ENOENT)
      {
         unlink( c_old); // clean up
         return( NO);
      }
   }

   rval = rename( c_old, c_new);
   if( rval)
   {
      NSLog( @"file \"%s\" not renamed to \"%s\" : %s\n", c_old, c_new, strerror( errno));
      return( NO);
   }
   return( YES);
}

@end

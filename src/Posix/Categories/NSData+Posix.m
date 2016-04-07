/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSData+Posix.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSData+Posix.h"

#include <fcntl.h>
#include <sys/stat.h>


@implementation NSData( _Posix)

+ (id) dataWithContentsOfFile:(NSString *) path
{
   return( [[[NSData alloc] initWithContentsOfFile:path] autorelease]);
}


- (id) initWithContentsOfFile:(NSString *) path
{
   char          *filename;
   int           fd;
   struct stat   info;
   ssize_t       len;
   ssize_t       actual_len;
   char          *buf;
   
   filename = [path fileSystemRepresentation];
   fd = open( filename, O_RDONLY);
   if( fd != -1)
   {
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
               buf = MulleObjCAllocateNonZeroedMemory( len);
               if( buf)
               {
                  // The system guarantees to read the number of bytes requested 
                  // if the descriptor references a normal file that has that 
                  // many bytes left before the end-of-file, but in no other case
                  
                  actual_len = read( fd, buf, len);
                  if( actual_len != -1)
                  {
                     if( actual_len != len)
                        buf = MulleObjCReallocateNonZeroedMemory( buf, actual_len);
                  }
               }
            }
            else
               errno = EFBIG;
         }
      }
      close( fd);
      
      if( buf)
      {
         // use "hidden" _init, since we are not using malloc
         return( [self _initWithBytesNoCopy:buf
                                     length:actual_len
                               freeWhenDone:YES]);
      }
   }      
   [self autorelease];
   return( nil);
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
   c_path    = [new_path fileSystemRepresentation];
   
   fd = open( c_path, O_WRONLY|O_CREAT|O_TRUNC, 0666 );
   if( fd == -1)
      return( NO);
   
   len = [self length];
   if( write( fd, [self bytes], len) != len)
   {
      close( fd);
      return( NO);
   }
   close( fd );
   
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

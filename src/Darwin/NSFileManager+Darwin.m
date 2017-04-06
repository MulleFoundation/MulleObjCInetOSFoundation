//
//  NSFileManager+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 28.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _DARWIN_C_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// std-c and dependencies
#include <sys/stat.h>
#include <sys/time.h>
#include <dirent.h>
#include <float.h>
#include <unistd.h>


@implementation NSFileManager (Darwin)

+ (SEL *) categoryDependencies
{
   static SEL   dependencies[] =
   {
      @selector( Posix),
      0
   };
   
   return( dependencies);
}


//
// is the idea, that NSFileManager can manage various filesystems
// and convert to the proper encoding for each ?
//
- (char *) fileSystemRepresentationWithPath:(NSString *) path
{
   if( ! [path length] || ! [path canBeConvertedToEncoding:[NSString defaultCStringEncoding]])
   {
      errno = EINVAL;
      MulleObjCPOSIXSetCurrentErrnoError( NULL);
      return( NULL);
   }

   return( [path cString]);  // assume
}


- (NSString *) stringWithFileSystemRepresentation:(char *) s
                                           length:(NSUInteger) len
{
   return( [NSString stringWithCString:s
                                length:len]);
}


- (struct timespec) _getCTimeFromStat:(struct stat *) stat
{
   return( stat->st_ctimespec);
}


- (struct timespec) _getMTimeFromStat:(struct stat *) stat
{
   return( stat->st_mtimespec);
}


@end

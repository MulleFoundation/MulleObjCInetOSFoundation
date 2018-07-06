//
//  NSDirectoryEnumerator+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/private/NSFileManager-Private.h>

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <dirent.h>
#include <sys/stat.h>



@implementation NSDirectoryEnumerator (Posix)

- (instancetype) initWithFileManager:(NSFileManager *) manager
                  rootPath:(NSString *) root
             inheritedPath:(NSString *) inherited
{
   NSString   *path;

   [super init];

   // asssume opendir can do symblinks, if not we need to resolve
   path = [root stringByAppendingPathComponent:inherited];

   _dir = opendir( [path fileSystemRepresentation]);
   if( ! _dir)
   {
      [self release];
      return( nil);
   }

   _manager       = [manager retain];
   _rootPath      = [root copy];
   _inheritedPath = [inherited copy];

   return( self);
}

- (NSString *) _nextEntry:(int *) is_dir
{
   struct dirent    *entry;

   *is_dir = -1;
retry:
   entry = readdir( _dir);
   if( ! entry)
      return( nil);

   switch( [_manager _isValidDirectoryContentsFilenameAsCString:entry->d_name])
   {
   case _MulleObjCFilenameIsDot    :
   case _MulleObjCFilenameIsDotDot :
   case _MulleObjCFilenameIsNoFile : goto retry;
   default                         : break;
   }

   return( [[[NSString alloc] initWithCString:entry->d_name] autorelease]);
}


- (void) _close
{
   if( _dir)
   {
      closedir( _dir);
      _dir = 0;
   }
}


@end

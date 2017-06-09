//
//  NSBundle+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _XOPEN_SOURCE 700

#import "MulleObjCOSBaseFoundation.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <dlfcn.h>


@interface NSBundle (Private)

- (void) willLoad;
- (void) didLoad;

@end


@implementation NSBundle (Posix)

- (BOOL) load
{
   NSString  *exePath;
   char      *c_path;

   exePath  = [self executablePath];
   c_path   = [exePath fileSystemRepresentation];
   if( ! c_path)
   {
      errno = EINVAL;
      return( NO);
   }

   [self willLoad];

   // check to see if alreay loaded
   // RTLD_LAZY | RTLD_GLOBAL crashed for me
   _handle = dlopen( c_path, RTLD_LAZY);
   if( ! _handle)
      return( NO);

   [self didLoad];

   return( YES);
}


- (BOOL) unload
{
   if( _handle)
   {
      if( dlclose( _handle))
         MulleObjCThrowInternalInconsistencyException( @"dlclose: %s", dlerror());
      _handle = NULL;
   }

   return( NO);
}

@end

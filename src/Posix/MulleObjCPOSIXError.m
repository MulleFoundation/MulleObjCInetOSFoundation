//
//  NSError+Posix.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 26.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

#import "MulleObjCPOSIXError.h"

// other files in this library

// std-c and dependencies
#include <errno.h>


NSString   *NSPOSIXErrorDomain = @"NSPOSIXError";


void     MulleObjCPOSIXSetCurrentErrnoError( NSError **error_p)
{
   NSString       *s;
   NSError        *error;
   NSDictionary   *info;

   assert( errno);
   s = [NSString stringWithCString:strerror( errno)];

   info  = [NSDictionary dictionaryWithObject:s
                                       forKey:NSLocalizedDescriptionKey];
   error = [NSError errorWithDomain:NSPOSIXErrorDomain
                               code:errno
                           userInfo:info];

   if( error_p)
      *error_p = error;

   [NSError setCurrentError:error];
}


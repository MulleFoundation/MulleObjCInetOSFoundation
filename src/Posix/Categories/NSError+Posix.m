//
//  NSError+Posix.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 26.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "NSError+Posix.h"

// other files in this library
#import "NSString+CString.h"

// std-c and dependencies
#include <errno.h>


NSString   *NSPOSIXErrorDomain = @"NSPOSIXError";


void     MulleObjCSetCurrentErrnoError( NSError **error_p)
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


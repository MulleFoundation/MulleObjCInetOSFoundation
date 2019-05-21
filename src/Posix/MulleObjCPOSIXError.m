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


@implementation MulleObjCPOSIXError : NSError


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (void) load
{
   [self mulleResetCurrentErrorClass];
}


+ (NSString *) mulleDefaultDomain
{
   return( NSPOSIXErrorDomain);
}

@end



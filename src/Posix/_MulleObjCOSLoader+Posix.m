//
//  _MulleObjCOSLoader+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "MulleObjCOSBaseFoundation.h"
#import "_MulleObjCOSLoader.h"
#import "NSPageAllocation.h"
#import "NSPageAllocation+Private.h"

// other files in this library

// std-c and dependencies
#include <unistd.h>


@implementation _MulleObjCOSLoader( Posix)

+ (void) load
{
   _MulleObjCSetPageSize( sysconf(_SC_PAGESIZE)); 
}

@end

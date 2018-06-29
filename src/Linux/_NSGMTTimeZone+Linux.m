//
//  _NSGMTTimeZone+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#define _BSD_SOURCE
#define _DEFAULT_SOURCE

#import "dependencies.h"

#import <MulleObjCStandardFoundation/private/_NSGMTTimeZone-Private.h>

#include <time.h>

@implementation _NSGMTTimeZone (Linux)

// gmtime: These functions are nonstandard GNU extensions that are also
//         present on the BSDs.  Avoid their use.
// Gives not alternative though ...
//
- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm
{
   return( timegm( tm));
}

@end

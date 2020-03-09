//
//  _MulleGMTTimeZone+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#define _BSD_SOURCE
#define _DEFAULT_SOURCE

#import "import-private.h"

#import <MulleObjCStandardFoundation/private/_MulleGMTTimeZone-Private.h>

#include <time.h>

@implementation _MulleGMTTimeZone (Linux)

// gmtime: These functions are nonstandard GNU extensions that are also
//         present on the BSDs.  Avoid their use.
// Gives not alternative though ...
//
- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm
{
   return( timegm( tm));
}

@end

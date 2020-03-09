//
//  _MulleGMTTimeZone+BSD.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

#import <MulleObjCStandardFoundation/private/_MulleGMTTimeZone-Private.h>

// std-c and dependencies
#include <time.h>


@implementation _MulleGMTTimeZone( BSD)

- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm
{
   return( timegm( tm));
}

@end

//
//  _NSGMTTimeZone+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCOSBaseFoundation.h"

#import <MulleObjCStandardFoundation/private/_NSGMTTimeZone.h>

#include <time.h>

@implementation _NSGMTTimeZone (Linux)

- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm
{
   return( timegm( tm));
}

@end

//
//  _NSGMTTimeZone+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "_NSGMTTimeZone+Linux.h"

#import <MulleObjCStandardFoundation/Private/_NSGMTTimeZone.h>


@implementation _NSGMTTimeZone (Linux)

- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm
{
   return( timegm( tm));
}

@end

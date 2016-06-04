//
//  NSCalendarDate+Linux.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 04.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <time.h>


@implementation NSCalendarDate (Linux)

+ (NSTimeInterval) _timeintervalSince1970WithTm:(struct tm *) tm
                                 secondsFromGMT:(NSUInteger) secondsFromGMT
{
   time_t   timeval;

   timeval = timegm( tm);
   return( timeval - secondsFromGMT);
}

@end

//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 04.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _DARWIN_C_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// std-c and dependencies
#include <time.h>


@implementation NSCalendarDate (Darwin)

+ (SEL *) categoryDependencies
{
   static SEL   dependencies[] =
   {
      @selector( Posix),
      0
   };

   return( dependencies);
}


- (instancetype) _initWithTM:(struct tm *) tm
                    timeZone:(NSTimeZone *) tz
{
   time_t           timeval;
   NSTimeInterval   interval;

   timeval  = timegm( tm);
   interval = timeval - [tz secondsFromGMT];

   return( [self initWithTimeIntervalSince1970:interval
                                      timeZone:tz]);
}

@end

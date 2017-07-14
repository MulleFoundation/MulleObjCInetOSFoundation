//
//  NSCalendarDate+BSD.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 04.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "MulleObjCPosixFoundation.h"

// other files in this library

// std-c and dependencies
#include <time.h>


@implementation NSCalendarDate( BSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
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

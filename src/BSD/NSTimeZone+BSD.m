//
//  NSTimeZone+BSD.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 23.06.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCPosixFoundation/private/NSTimeZone+Posix-Private.h>


@implementation NSTimeZone (BSD)

- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm
{
   extern long        mulle_get_timeinterval_for_tm( void *, struct tz_tm *);
   struct tz_tm       tmp;
   NSTimeInterval     interval;

   tmp.tm_sec  = tm->tm_sec;
   tmp.tm_min  = tm->tm_min;
   tmp.tm_hour = tm->tm_hour;
   tmp.tm_mday = tm->tm_mday;
   tmp.tm_mon  = tm->tm_mon;
   tmp.tm_year = tm->tm_year;

   tmp.tm_zone  = NULL;
   tmp.tm_isdst = tm->tm_isdst;
   tmp.tm_wday  = 0;
   tmp.tm_yday  = 0;

   interval = (NSTimeInterval) mulle_get_timeinterval_for_tm( [_data bytes], &tmp);
   if( interval == -1)
      MulleObjCThrowInvalidArgumentException( @"time can not be converted");

   tm->tm_sec  = tmp.tm_sec;
   tm->tm_min  = tmp.tm_min;
   tm->tm_hour = tmp.tm_hour;
   tm->tm_mday = tmp.tm_mday;
   tm->tm_mon  = tmp.tm_mon;
   tm->tm_year = tmp.tm_year;

   tm->tm_zone  = tmp.tm_zone;
   tm->tm_isdst = tmp.tm_isdst;
   tm->tm_wday  = tmp.tm_wday;
   tm->tm_yday  = tmp.tm_yday;

   return( interval);
}

@end

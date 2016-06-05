//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#include "mulle_posix_tm.h"

// std-c and dependencies
#include <time.h>
#include <locale.h>


@implementation NSDate (Linux)

+ (NSDate *) _dateWithCStringFormat:(char *) c_format
                             locale:(NSLocale *) locale
                           timeZone:(NSTimeZone *) timeZone
                          isLenient:(BOOL) lenient
                     cStringPointer:(char **) c_str_p
{
   NSDate           *date;
   NSInteger        estSeconds;
   NSInteger        realSeconds;
   NSTimeInterval   interval;
   NSUInteger       loops;
   int              rval;
   struct tm        tm;
   
   rval = mulle_posix_tm_from_string_with_format( &tm,
                                                  c_str_p,
                                                  c_format,
                                                  [locale xlocale],
                                                  lenient);
   if( rval < 0)
      return( nil);
   
   realSeconds = 0;
   estSeconds  = [timeZone secondsFromGMT];

   // if we flipflop forever return
   for( loops = 8; loops ; --loops)
   {
      interval    = [NSCalendarDate _timeintervalSince1970WithTm:&tm
                                                  secondsFromGMT:estSeconds];
      date        = [self dateWithTimeIntervalSince1970:interval];
      if( ! has_tz)
         realSeconds = [timeZone secondsFromGMTForDate:date];
      if( realSeconds == estSeconds)
        break;

      estSeconds = realSeconds;
   }
   
   if( ! loops)
      NSLog( @"Date %@ is possibly off by %ld seconds", date, realSeconds - estSeconds);
   
   return( date);
}


- (size_t) _getAsCString:(char *) buf
                  length:(size_t) len
           cStringFormat:(char *) c_format
                  locale:(NSLocale *) locale
                timeZone:(NSTimeZone *) timeZone
{
   locale_t    old_locale;
   struct tm   tm;
   
   mulle_posix_tm_with_timeintervalsince1970( &tm,
                                              (double) [self timeIntervalSince1970],
                                              (unsigned int) [timeZone secondsFromGMTForDate:self]);
   
   old_locale  = uselocale( [locale xlocale]);
   {
      len = strftime( buf, len, c_format, &tm);
   }
   uselocale( old_locale);
   
   return( len);
}


@end

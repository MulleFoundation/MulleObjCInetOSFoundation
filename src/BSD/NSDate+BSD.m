//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCPosixFoundation.h"

// other files in this library
#include "mulle_bsd_tm.h"

// other libraries of MulleObjCPosixFoundation
#import "NSLocale+PosixPrivate.h"
#include "mulle_posix_tm.h"

// std-c and dependencies
#include <time.h>
#include <xlocale.h>


@implementation NSDate( BSD)

+ (SEL *) categoryDependencies
{
   static SEL   dependencies[] =
   {
      @selector( Posix),
      0
   };
   
   return( dependencies);
}


+ (NSDate *) _dateWithCStringFormat:(char *) c_format
                             locale:(NSLocale *) locale
                           timeZone:(NSTimeZone *) timeZone
                          isLenient:(BOOL) lenient
                     cStringPointer:(char **) c_str_p
{
   NSDate           *date;
   NSInteger        estSeconds;
   NSInteger        realSeconds;
   NSUInteger       loops;
   int              has_tz;
   struct tm        tm;

   has_tz = mulle_bsd_tm_from_string_with_format( &tm,
                                                  c_str_p,
                                                  c_format,
                                                  [locale xlocale],
                                                  lenient);
   if( has_tz < 0)
      return( nil);

   estSeconds = 0;
   realSeconds = 0;
   if( ! has_tz)
      estSeconds = [timeZone secondsFromGMT];

   // if we flipflop forever return
   for( loops = 8; loops ; --loops)
   {
      time_t   timeval;

      timeval = timegm( &tm);
      date    = [self dateWithTimeIntervalSince1970:(NSTimeInterval) timeval];
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
   locale_t    xlocale;
   struct tm   tm;

   mulle_posix_tm_with_timeintervalsince1970( &tm,
                                              (double) [self timeIntervalSince1970],
                                              (unsigned int) [timeZone secondsFromGMTForDate:self]);

   xlocale  = [locale xlocale];
   if( xlocale)
      len = strftime_l( buf, len, c_format, &tm, xlocale);
   else
      len = strftime( buf, len, c_format, &tm);
   return( len);
}


@end

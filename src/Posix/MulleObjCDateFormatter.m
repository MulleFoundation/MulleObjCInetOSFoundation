//
//  MulleObjCDateFormatter.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "MulleObjCDateFormatter.h"

// other files in this library
#import "NSCalendarDate.h"
#import "NSError+Posix.h"
#import "NSLocale+Posix.h"
#import "NSLocale+PosixPrivate.h"
#import "NSString+CString.h"
#import "NSLog.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <time.h>
#include <xlocale.h>
#include <alloca.h>


@implementation MulleObjCDateFormatter

+ (void) load
{
   @autoreleasepool
   {
      [NSDateFormatter setClassValue:self
                              forKey:NSDateFormatter1000BehaviourClassKey];
      [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_0];
   }
}


- (NSDateFormatterBehavior) formatterBehavior
{
   return( NSDateFormatterBehavior10_0);
}


- (instancetype) _initWithDateFormat:(NSString *) format
                allowNaturalLanguage:(BOOL) flag
{
   size_t   length;
   
   self = [super _initWithDateFormat:format
                allowNaturalLanguage:flag];
   if( self)
   {
      length   = [format cStringLength];
      _cformat = MulleObjCObjectAllocateNonZeroedMemory( self, length + 1);
      [format getCString:_cformat
               maxLength:length+1];

      // just a heuristic
      length *= 4;
      if( length < 256)
         length = 256;
      
      _buflen = length;
   }
   return( self);
}


- (void) dealloc
{
   MulleObjCObjectDeallocateMemory( self, _cformat);
   [super dealloc];
}


#pragma mark -
#pragma mark conversions

static size_t   mulle_cstring_from_date( char *buf, size_t len, NSDate *date, char *format, NSLocale *locale, NSTimeZone *timeZone)
{
   locale_t    xlocale;
   struct tm   tm;
   
   mulle_tm_with_timeintervalsince1970( &tm, [date timeIntervalSince1970], [timeZone secondsFromGMTForDate:date]);
   
   xlocale  = [locale xlocale];
   if( xlocale)
      len = strftime_l( buf, len, format, &tm, xlocale);
   else
      len = strftime( buf, len, format, &tm);
   return( len);
}


static void   set_tm_to_invalid( struct tm *tm)
{
   tm->tm_sec    = INT_MIN;
   tm->tm_min    = INT_MIN;
   tm->tm_hour   = INT_MIN;
   tm->tm_mday   = INT_MIN;
   tm->tm_mon    = INT_MIN;
   tm->tm_year   = INT_MIN;
   tm->tm_wday   = INT_MIN;
   tm->tm_yday   = INT_MIN;
   tm->tm_isdst  = INT_MIN;
   tm->tm_gmtoff = LONG_MIN; // LONG_MIN here
   tm->tm_zone   = (void *) &tm;  // surely NOT a zone address
}


static int   has_tm_invalid_fields( struct tm *tm)
{
   if( tm->tm_sec == INT_MIN)
      return( 1);
   if( tm->tm_min == INT_MIN)
      return( 1);
   if( tm->tm_hour == INT_MIN)
      return( 1);
   if( tm->tm_mday == INT_MIN && tm->tm_wday == INT_MIN && tm->tm_yday == INT_MIN)
      return( 1);
   if( tm->tm_year == INT_MIN)
      return( 1);
   if( tm->tm_gmtoff == LONG_MIN && tm->tm_zone == (void *) tm)
      return( 1);
   
   return( 0);
}


static unsigned int   augment_tm_with_tm( struct tm *tm, struct tm *now, int *has_tz)
{
   unsigned int  n;
   
   n = 0;

   *has_tz = 0;
   if( tm->tm_sec == INT_MIN)
   {
      ++n;
      tm->tm_sec = now->tm_sec;
   }
   if( tm->tm_min == INT_MIN)
   {
      ++n;
      tm->tm_min = now->tm_min;
   }
   if( tm->tm_hour == INT_MIN)
   {
      ++n;
      tm->tm_hour = now->tm_hour;
   }
   if( tm->tm_mday == INT_MIN && tm->tm_wday == INT_MIN && tm->tm_yday == INT_MIN)
   {
      ++n;
      tm->tm_mday = now->tm_mday;
   }
   
   if( tm->tm_mon == INT_MIN)
   {
      ++n;
      tm->tm_mon = now->tm_mon;
   }
   if( tm->tm_year == INT_MIN)
   {
      ++n;
      tm->tm_year = now->tm_year;
   }
   
   if( tm->tm_gmtoff == LONG_MIN && tm->tm_zone == (char *) &tm)
   {
      ++n;
      tm->tm_gmtoff = now->tm_gmtoff;
      *has_tz       = 1;
   }
   return( n);
}



static NSDate  *mulle_date_from_cstring( char *c_format, Class dateClass, BOOL lenient, NSLocale *locale, NSTimeZone *timeZone, char  **c_str_p)
{
   NSDate           *date;
   NSInteger        estSeconds;
   NSInteger        realSeconds;
   NSTimeInterval   interval;
   NSUInteger       loops;
   char             *c_str;
   int              has_tz;
   locale_t         xlocale;
   struct tm        now;
   struct tm        tm;
   time_t           nowtimeval;
   unsigned int     n;
   
   // set it all to int min, that way we can deduce how much
   // strptime was able to parse for "leniency"
  
   set_tm_to_invalid( &tm);
   
   xlocale = [locale xlocale];
   c_str   = *c_str_p;

   if( xlocale)
      *c_str_p  = strptime_l( c_str, c_format, &tm, xlocale);
   else
      *c_str_p  = strptime( c_str, c_format, &tm);
   
   if( ! *c_str_p)
   {
      if( ! lenient)
         return( nil);
   }

   has_tz = 1;
   if( has_tm_invalid_fields( &tm))
   {
      // augment formatter with current time (or only when parsing failed ?)
      nowtimeval = time( NULL);
      gmtime_r( &nowtimeval, &now);  // localtime, gmtime ???
      
      n = augment_tm_with_tm( &tm, &now, &has_tz);

      // absolutely no conversion and we failed parsing, strange
      if( ! n && ! *c_str_p)
         return( nil);
   }
   
   estSeconds = 0;
   realSeconds = 0;
   if( ! has_tz)
      estSeconds = [timeZone secondsFromGMT];

   // if we flipflop forever return
   for( loops = 8; loops ; --loops)
   {
      interval    = [NSCalendarDate _timeintervalSince1970WithTm:&tm
                                                  secondsFromGMT:estSeconds];
      date        = [dateClass dateWithTimeIntervalSince1970:interval];
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


//
// a NSDate is a GMT date, it should be rendered as GMT alas
// the user may specify a timeZone...
//
- (NSString *) stringFromDate:(NSDate *) date
{
   size_t   len;
   char     *buf;
   
   for(;;)
   {
      buf = alloca( _buflen);

      len = mulle_cstring_from_date( buf, _buflen, date, _cformat, [self locale], [self timeZone]);
      if( len)
         return( [NSString stringWithCString:buf
                                      length:len + 1]);
      _buflen *= 2;  // weak ...
   }
}


- (NSDate *) dateFromString:(NSString *) s
{
   char     *c_str;
   NSDate   *date;
   
   c_str = [s cString];
   date  = mulle_date_from_cstring( _cformat, _dateClass, [self isLenient], [self locale], [self timeZone], &c_str);
   return( date);
}


- (BOOL) getObjectValue:(id *) obj
              forString:(NSString *) string
                  range:(NSRange *) rangep
                  error:(NSError **) error
{
   char     *c_begin;
   char     *c_end;
   NSDate   *date;
   
   c_begin = [string cString];
   c_end   = c_begin;
   date  = mulle_date_from_cstring( _cformat, _dateClass,  [self isLenient], [self locale], [self timeZone], &c_end);
   if( ! date)
   {
      errno = EINVAL; // whatever
      MulleObjCSetCurrentErrnoError( error);
      return( NO);
   }
   
   *obj = date;
   if( rangep)
      *rangep = NSMakeRange( 0, c_end - c_begin);
   return( YES);
}

@end

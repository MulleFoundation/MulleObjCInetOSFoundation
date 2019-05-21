//
//  NSCalendarDate+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

// TODO: move stuff to Linux/Darwin because of timegm

#define _XOPEN_SOURCE 700  // linux: for various stuff
#define _DARWIN_C_SOURCE   // darwin: for timegm
#define _USE_MISC          // linux: for timegm
#define _GNUSOURCE         // linux: for timegm

#import "import-private.h"

// std-c and dependencies
#include <time.h>

// private stuff
#include "NSCalendarDate+Posix-Private.h"
#include "NSTimeZone+Posix-Private.h"
#include "mulle_posix_tm-private.h"


struct mulle_mini_tm  mulle_mini_tm_with_tm( struct tm *src)
{
   struct mulle_mini_tm   dst;

   dst.year   = src->tm_year + 1900;
   dst.month  = src->tm_mon;
   dst.day    = src->tm_mday;
   dst.hour   = src->tm_hour;
   dst.minute = src->tm_min;
   dst.second = src->tm_sec;
   dst.ns     = 0;

   return( dst);
}


void  mulle_tm_with_mini_tm( struct tm  *dst, struct mulle_mini_tm src)
{
   memset( dst, 0, sizeof( *dst)); // most compatible, though wasteful

   dst->tm_year   = src.year - 1900;
   dst->tm_mon    = src.month;
   dst->tm_mday   = src.day;
   dst->tm_hour   = src.hour;
   dst->tm_min    = src.minute;
   dst->tm_sec    = src.second;
}


@implementation NSCalendarDate (Posix)

static void  set_mini_tm( NSCalendarDate *self, NSTimeInterval interval, int tzOffset)
{
   struct tm   tmp;

   mulle_posix_tm_with_timeintervalsince1970( &tmp,
                                              interval,
                                              (int) tzOffset);
   self->_tm.values = mulle_mini_tm_with_tm( &tmp);
}


// use specified tz or "GMT" as default
- (instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
                                      timeZone:(NSTimeZone *) timeZone
{
   if( ! timeZone)
      timeZone = [NSTimeZone _GMTTimeZone];  // GMT sic!
   _timeZone = [timeZone retain];
   assert( _timeZone);

   set_mini_tm( self, timeInterval, (int) [_timeZone secondsFromGMT]);

   return( self);
}

 // unspecified tz ? use here
- (instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
{
   _timeZone = [[NSTimeZone defaultTimeZone] retain];
   assert( _timeZone);

   set_mini_tm( self, timeInterval, (int) [_timeZone secondsFromGMT]);

   return( self);
}


- (instancetype) init
{
   NSTimeInterval   seconds;

   seconds = time( NULL) + NSTimeIntervalSince1970;
   return( [self initWithTimeIntervalSinceReferenceDate:seconds]);
}


- (instancetype) initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) timeInterval
{
   return( [self initWithTimeIntervalSince1970:timeInterval + NSTimeIntervalSince1970]);
}


- (instancetype) initWithDate:(NSDate *) date
                     timeZone:(NSTimeZone *) tz
{
   return( [self initWithTimeIntervalSince1970:[date timeIntervalSince1970]
                                      timeZone:tz]);
}


- (instancetype) _initWithDate:(NSDate *) date
{
   return( [self initWithTimeIntervalSince1970:[date timeIntervalSince1970]
                                      timeZone:nil]);
}


- (NSCalendarDate *) dateByAddingYears:(NSInteger) years
                                months:(NSInteger) months
                                  days:(NSInteger) days
                                 hours:(NSInteger) hours
                               minutes:(NSInteger) minutes
                               seconds:(NSInteger) seconds
{
   struct tm   tmp;

   mulle_tm_with_mini_tm( &tmp, self->_tm.values);

   tmp.tm_year  += years;
   tmp.tm_mon   += months;
   tmp.tm_mday  += days;

   tmp.tm_hour  += hours;
   tmp.tm_min   += minutes;
   tmp.tm_sec   += seconds;

   return( [[[[self class] alloc] _initWithTM:&tmp
                                     timeZone:_timeZone] autorelease]);
}


- (NSTimeInterval) timeIntervalSinceReferenceDate
{
   return( [self timeIntervalSince1970] - NSTimeIntervalSince1970);
}


- (NSTimeInterval) timeIntervalSince1970
{
   struct tm   tmp;
   time_t      value;

   mulle_tm_with_mini_tm( &tmp, self->_tm.values);
   value = timegm( &tmp);
   value -= [_timeZone _secondsFromGMTForTimeIntervalSince1970:value];
   return( (NSTimeInterval) value);
}


- (NSDate *) date
{
   // convert to GMT
   return( [NSDate dateWithTimeIntervalSince1970:[self timeIntervalSince1970]]);
}

@end

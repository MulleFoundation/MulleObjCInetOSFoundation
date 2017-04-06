//
//  NSCalendarDate+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#define _XOPEN_SOURCE 700

#import "MulleObjCOSBaseFoundation.h"

// other libraries of MulleObjCPosixFoundation
#include "NSCalendarDate+PosixPrivate.h"
#include "mulle_posix_tm.h"

// std-c and dependencies


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
   dst->tm_year   = src.year - 1900;
   dst->tm_mon    = src.month;
   dst->tm_mday   = src.day;
   dst->tm_hour   = src.hour;
   dst->tm_min    = src.minute;
   dst->tm_sec    = src.second;
   
   dst->tm_isdst  = 0;
   dst->tm_wday   = 0;
   dst->tm_yday   = 0;
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


- (id) initWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
                            timeZone:(NSTimeZone *) timeZone
{
   _timeZone = [timeZone retain];
   set_mini_tm( self, timeInterval, (int) [_timeZone secondsFromGMT]);

   return( self);
}

- (id) initWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
{
   _timeZone = [[NSTimeZone defaultTimeZone] retain];
   set_mini_tm( self, timeInterval, (int) [_timeZone secondsFromGMT]);

   return( self);
}


- (instancetype) initWithDate:(NSDate *) date
                     timeZone:(NSTimeZone *) tz
{
   return( [self initWithTimeIntervalSince1970:[date timeIntervalSince1970]
                                      timeZone:tz]);
}


+ (instancetype) calendarDate
{
   NSTimeInterval   seconds;
   
   seconds = time( NULL) + NSTimeIntervalSince1970;
   return( [[[self alloc] initWithTimeIntervalSinceReferenceDate:seconds] autorelease]);
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

   tmp.tm_gmtoff = 0;
   tmp.tm_isdst  = 0;
   tmp.tm_wday   = 0;
   tmp.tm_yday   = 0;

   return( [[[[self class] alloc] _initWithTM:&tmp
                                     timeZone:_timeZone] autorelease]);
}

@end

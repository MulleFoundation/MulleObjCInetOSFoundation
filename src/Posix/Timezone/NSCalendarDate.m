//
//  NSCalendarDate.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSCalendarDate.h"

// other files in this library
#import "NSLocale+Posix.h"
#import "NSTimeZone+Posix.h"

// std-c and dependencies


static void  mulle_mini_tm_with_tm( struct mulle_mini_tm *dst, struct tm *src)
{
   dst->year   = src->tm_year + 1900;
   dst->month  = src->tm_mon;
   dst->day    = src->tm_mday;
   dst->hour   = src->tm_hour;
   dst->minute = src->tm_min;
   dst->second = src->tm_sec;
   dst->ns     = 0;
}


static void  mulle_tm_with_mini_tm( struct tm  *dst, struct mulle_mini_tm *src)
{
   dst->tm_year   = src->year - 1900;
   dst->tm_mon    = src->month;
   dst->tm_mday   = src->day;
   dst->tm_hour   = src->hour;
   dst->tm_min    = src->minute;
   dst->tm_sec    = src->second;

   dst->tm_isdst  = 0;
   dst->tm_wday   = 0;
   dst->tm_yday   = 0;
#if 0
   dst->tm_zone   = NULL;
   dst->tm_gmtoff = 0;
#endif   
}


void  mulle_tm_with_timeintervalsince1970( struct tm *tm, NSTimeInterval timeInterval, NSInteger secondsFromGMT)
{
   time_t      timeval;

   timeval = (time_t) (timeInterval + secondsFromGMT + 0.5);
   gmtime_r( &timeval, tm);
   tm->tm_gmtoff = secondsFromGMT;
}



@implementation NSCalendarDate

#pragma mark -
#pragma mark init

- (id) initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) interval
{
   NSString   *s;
   
   [super initWithTimeIntervalSinceReferenceDate:interval];

   s = [[NSLocale currentLocale] objectForKey:NSTimeDateFormatString];
   if( ! s)
      s = @"%A, %B %e, %Y %1I:%M:%S %p %Z";
   
   _calendarFormat = [s copy];
   _timeZone       = [[NSTimeZone defaultTimeZone] retain];
   
   return( self);
}


- (instancetype) _initWithTM:(struct tm *) tm
                    timeZone:(NSTimeZone *) tz
{
   NSTimeInterval   interval;
   
   interval = [isa _timeintervalSince1970WithTm:tm
                                 secondsFromGMT:[tz secondsFromGMT]];
   
   self = [self initWithTimeIntervalSince1970:interval];
   if( self)
      mulle_mini_tm_with_tm( &self->_tm.values, tm);
   return( self);
}



+ (instancetype) calendarDate
{  
   NSTimeInterval   seconds;
   
   seconds = time( NULL) + NSTimeIntervalSince1970;
   return( [[[self alloc] initWithTimeIntervalSinceReferenceDate:seconds] autorelease]);
}


+ (instancetype) dateWithYear:(NSInteger) year
                        month:(NSUInteger) month
                          day:(NSUInteger) day
                         hour:(NSUInteger) hour
                       minute:(NSUInteger) minute
                       second:(NSUInteger) second
                     timeZone:(NSTimeZone *) tz
{
   return( [[[self alloc] initWithYear:year
                                 month:month
                                   day:day
                                  hour:hour
                                minute:minute
                                second:second
                              timeZone:tz] autorelease]);
}


- (NSCalendarDate *) dateByAddingYears:(NSInteger) year
                                months:(NSInteger) month
                                  days:(NSInteger) day
                                 hours:(NSInteger) hour
                               minutes:(NSInteger) minute
                               seconds:(NSInteger) second
{
   struct tm   tmp;
   
   get_tm( self, &tmp);
   tmp.tm_year += year;
   tmp.tm_mon  += month;
   tmp.tm_mday += day;
   tmp.tm_hour += hour;
   tmp.tm_min  += minute;
   tmp.tm_sec  += second;
   
   return( [[[isa alloc] _initWithTM:&tmp
                            timeZone:_timeZone] autorelease]);
}




- (instancetype) initWithYear:(NSInteger) year
                        month:(NSUInteger) month
                          day:(NSUInteger) day
                         hour:(NSUInteger) hour minute:(NSUInteger) minute
                       second:(NSUInteger) second
                     timeZone:(NSTimeZone *) tz
{
   struct tm        tmp;
   NSTimeInterval   interval;
   
   tmp.tm_gmtoff = 0;
   tmp.tm_year   = (int) (year - 1900);
   tmp.tm_mon    = (int) month;
   tmp.tm_mday   = (int) day;
   tmp.tm_hour   = (int) hour;
   tmp.tm_sec    = (int) second;
   tmp.tm_min    = (int) minute;
   
   tmp.tm_zone   = NULL;
   tmp.tm_wday   = 0;
   tmp.tm_yday   = 0;
   
   interval = [isa _timeintervalSince1970WithTm:&tmp
                                 secondsFromGMT:[tz secondsFromGMT]];
   
   self = [self initWithTimeIntervalSince1970:interval];
   if( self)
      mulle_mini_tm_with_tm( &self->_tm.values, &tmp);
   return( self);
}


//- (NSInteger) dayOfCommonEra
//{
//   
//}


static void  get_tm( NSCalendarDate *self, struct tm *dst)
{
   NSInteger   seconds;
   
   seconds = [self->_timeZone secondsFromGMT];
   mulle_tm_with_timeintervalsince1970( dst, self->_interval, seconds);
}


static void  create_mini_tm( NSCalendarDate *self)
{
   struct tm   tmp;
   
   get_tm( self, &tmp);
   mulle_mini_tm_with_tm( &self->_tm.values, &tmp);
}


- (NSInteger) dayOfMonth
{
   if( ! self->_tm.bits)
      create_mini_tm( self);
   return( self->_tm.values.day);
}


- (NSInteger) dayOfWeek
{
   struct tm   tmp;
   
   get_tm( self, &tmp);
   return( tmp.tm_wday);
}


- (NSInteger) dayOfYear
{
   struct tm   tmp;
   
   get_tm( self, &tmp);
   return( tmp.tm_yday);
}


- (NSInteger) hourOfDay
{
   if( ! self->_tm.bits)
      create_mini_tm( self);
   return( self->_tm.values.hour);
}

- (NSInteger) minuteOfHour
{
   if( ! self->_tm.bits)
      create_mini_tm( self);
   return( self->_tm.values.minute);
}

- (NSInteger) monthOfYear
{
   if( ! self->_tm.bits)
      create_mini_tm( self);
   return( self->_tm.values.month);
}

- (NSInteger) secondOfMinute
{
   if( ! self->_tm.bits)
      create_mini_tm( self);
   return( self->_tm.values.second);
}

- (NSInteger) yearOfCommonEra
{
   if( ! self->_tm.bits)
      create_mini_tm( self);
   return( self->_tm.values.year);
}


//- (void) years:(NSInteger *) yp
//        months:(NSInteger *) mop
//          days:(NSInteger *) dp
//         hours:(NSInteger *) hp
//       minutes:(NSInteger *) mip
//       seconds:(NSInteger *) sp
//     sinceDate:(NSCalendarDate *) date;
//{
//}


+ (id) dateWithString:(NSString *) s
       calendarFormat:(NSString *) format
               locale:(NSLocale *) locale
{
   NSDateFormatter   *formatter;
   
   formatter = [[[NSDateFormatter alloc] initWithDateFormat:format
                                       allowNaturalLanguage:YES] autorelease];
   [formatter setGenerateCalendarDates:YES];
   [formatter setLocale:locale];

   return( [formatter dateFromString:s]);
}


+ (id) dateWithString:(NSString *) s
       calendarFormat:(NSString *) format
{
   return( [self dateWithString:s
                 calendarFormat:format
                         locale:[NSLocale currentLocale]]);
}


- (instancetype) initWithString:(NSString *) s
                 calendarFormat:(NSString *) format
                         locale:(id) locale
{
   NSDateFormatter   *formatter;
   
   formatter = [[[NSDateFormatter alloc] initWithDateFormat:format
                                       allowNaturalLanguage:YES] autorelease];
   [formatter setGenerateCalendarDates:YES];
   [formatter setLocale:locale];

   [self release];

   self = (id) [[formatter dateFromString:s] retain];
   return( self);
}


- (instancetype) initWithString:(NSString *) s
                 calendarFormat:(NSString *) format
{
   return( [self initWithString:s
                          calendarFormat:format
                                  locale:[NSLocale currentLocale]]);
}

- (instancetype) initWithString:(NSString *) s;
{
   NSLocale   *locale;
   
   locale = [NSLocale currentLocale];
   return( [self initWithString:s
                  calendarFormat:[locale objectForKey:NSTimeDateFormatString]
                          locale:locale]);
}

                              
- (NSString *) descriptionWithCalendarFormat:(NSString *) format
                                      locale:(NSLocale *) locale
{
   NSDateFormatter   *formatter;
   
   formatter = [[[NSDateFormatter alloc] initWithDateFormat:format
                                       allowNaturalLanguage:NO] autorelease];
   [formatter setLocale:locale];
   [formatter setTimeZone:[self timeZone]];
   return( [formatter stringFromDate:self]);
}


- (NSString *) descriptionWithCalendarFormat:(NSString *) format
{
   return( [self descriptionWithCalendarFormat:format
                                        locale:[NSLocale currentLocale]]);
}


- (NSString *) descriptionWithLocale:(NSLocale *) locale
{
   return( [self descriptionWithCalendarFormat:[self calendarFormat]
                                        locale:locale]);
}


- (NSString *) description
{
   return( [self descriptionWithCalendarFormat:[self calendarFormat]
                                        locale:[NSLocale currentLocale]]);
}

@end

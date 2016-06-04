//
//  NSCalendarDate.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjCFoundation/MulleObjCFoundation.h>


#include <time.h>

// 64 bit large
struct mulle_mini_tm
{
   int              year    : 18;   // -100000  +100000 (?)
   unsigned int     month   : 4;    // 1-12 (15)
   unsigned int     day     : 5;    // 1-31 (31)
   unsigned int     hour    : 5;    // 0-23 (31)
   unsigned int     minute  : 6;    // 0-59 (63)
   unsigned int     second  : 6;    // 0-59 (63)
   unsigned int     ns      : 20;   // 0-999 (1023)  **unused **
};


@interface NSCalendarDate : NSDate
{
   union
   {
      uint64_t               bits;
      struct mulle_mini_tm   values;
   } _tm;
}

@property( assign) NSTimeZone   *timeZone;
@property( copy) NSString       *calendarFormat;

+ (instancetype) calendarDate;
+ (instancetype) dateWithYear:(NSInteger) year
                        month:(NSUInteger) month
                          day:(NSUInteger) day
                         hour:(NSUInteger) hour
                       minute:(NSUInteger) minute
                       second:(NSUInteger) second
                     timeZone:(NSTimeZone *)aTimeZone;

- (NSCalendarDate *) dateByAddingYears:(NSInteger) year
                                months:(NSInteger) month
                                  days:(NSInteger) day
                                 hours:(NSInteger) hour
                               minutes:(NSInteger) minute
                               seconds:(NSInteger) second;

- (instancetype) initWithYear:(NSInteger) year
                        month:(NSUInteger) month
                          day:(NSUInteger) day
                         hour:(NSUInteger) hour minute:(NSUInteger) minute
                       second:(NSUInteger) second
                     timeZone:(NSTimeZone *)aTimeZone;

//- (NSInteger) dayOfCommonEra;
- (NSInteger) dayOfMonth;
- (NSInteger) dayOfWeek;
- (NSInteger) dayOfYear;
- (NSInteger) hourOfDay;
- (NSInteger) minuteOfHour;
- (NSInteger) monthOfYear;
- (NSInteger) secondOfMinute;
- (NSInteger) yearOfCommonEra;

- (void) years:(NSInteger *) yp
        months:(NSInteger *) mop
          days:(NSInteger *) dp
         hours:(NSInteger *) hp
       minutes:(NSInteger *) mip
       seconds:(NSInteger *) sp
     sinceDate:(NSCalendarDate *) date;

@end


@interface NSCalendarDate( OSSpecific)

+ (NSTimeInterval) _timeintervalSince1970WithTm:(struct tm *) tm
                                 secondsFromGMT:(NSUInteger) secondsFromGMT;

@end


void    mulle_tm_with_timeintervalsince1970( struct tm *tm, NSTimeInterval timeInterval, NSInteger secondsFromGMT);


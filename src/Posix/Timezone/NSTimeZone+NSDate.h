/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSTimeZone+NSDate.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTimeZone.h"


@class NSDate;


@interface NSTimeZone( NSDate)

- (NSInteger) secondsFromGMT;
- (NSString *) abbreviation;
- (BOOL) isDaylightSavingTime;
- (id) description;

@end


@interface NSTimeZone( _Abstract_NSDate)

+ (id) timeZoneForSecondsFromGMT:(NSInteger) seconds;
- (NSInteger) secondsFromGMTForDate:(NSDate *) aDate;
- (NSString *) abbreviationForDate:(NSDate *) aDate;
- (BOOL) isDaylightSavingTimeForDate:(NSDate *) aDate;

@end

/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSTimeZone+NSDate.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTimeZone+NSDate.h"


@implementation NSTimeZone( NSDate)

- (NSInteger) secondsFromGMT
{
   return( [self secondsFromGMTForDate:[NSDate date]]);
}


- (NSString *) abbreviation
{
   return( [self abbreviationForDate:[NSDate date]]);
}


- (BOOL) isDaylightSavingTime
{
   return( [self isDaylightSavingTimeForDate:[NSDate date]]);
}


- (id) description
{
   return( [NSString stringWithFormat:@"%@ (%@) offset %ld%s",
                                 name_, 
                                 [self abbreviation], 
                                 [self secondsFromGMT], 
                                 [self isDaylightSavingTime] ? " (Daylight)" : ""]);
}

@end

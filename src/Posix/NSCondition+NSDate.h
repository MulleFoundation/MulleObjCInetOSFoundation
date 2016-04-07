/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSCondition+NSDate.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSCondition.h"


@class NSDate;


@interface NSCondition( NSDate)

- (BOOL) waitUntilDate:(NSDate *) date;

@end

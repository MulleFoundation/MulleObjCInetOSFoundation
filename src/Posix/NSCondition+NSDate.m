/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSCondition+NSDate.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSCondition+NSDate.h"

#include <time.h>


@implementation NSCondition( NSDate)

- (BOOL) waitUntilDate:(NSDate *) date
{
   struct timespec    wait_time;
   NSTimeInterval     interval;
   
   interval = [date timeIntervalSince1970];
   wait_time.tv_sec  = (long) interval;
   wait_time.tv_nsec = (long) ((interval - wait_time.tv_sec) * 1000000000);
   return( pthread_cond_timedwait( &self->_condition,
                                   &self->_lock,
                                   &wait_time) ? NO : YES);
}

@end

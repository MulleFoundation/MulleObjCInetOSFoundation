/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSCondition.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSCondition.h"

// other files in this library

// std-c and dependencies


@implementation NSCondition

- (instancetype) init
{
   pthread_mutex_init( &self->_lock, NULL);
   pthread_cond_init(  &self->_condition, NULL);
   return( self);
}


- (void) dealloc
{
   pthread_cond_destroy( &self->_condition);
   pthread_mutex_destroy( &self->_lock);

   [super dealloc];
}


- (void) signal
{
   pthread_cond_signal( &self->_condition);
}


- (void) broadcast
{
   pthread_cond_broadcast( &self->_condition);
}


- (void) wait
{
   pthread_cond_wait( &self->_condition, &self->_lock);
}



#pragma mark -
#pragma mark NSLocking

- (void) lock
{
   pthread_mutex_lock( &self->_lock);
}


- (void) unlock
{
   pthread_mutex_unlock( &self->_lock);
}



- (BOOL) tryLock
{
   return( pthread_mutex_trylock( &self->_lock) ? NO : YES);
}


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


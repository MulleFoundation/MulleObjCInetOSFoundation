/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSConditionLock.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSConditionLock.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSConditionLock

- (id) initWithCondition:(NSInteger) condition
{
   _lock             = [NSLock new];
   _currentCondition = condition;
   return( self);
}


- (void) dealloc
{
   [_lock release];
   [super dealloc];
}


- (NSInteger) condition
{
   return( _currentCondition);
}


- (void) lockWhenCondition:(NSInteger) condition
{
   for(;;)
   {
      [_lock lock];
      if( _currentCondition == condition)
         return;
         
      [_lock unlock];  // unlocks and wait lamely
      mulle_thread_yield();
   }
}


- (BOOL) tryLockWhenCondition:(NSInteger) condition
{
   if( ! [_lock tryLock])
      return( NO);
   
   if( _currentCondition == condition)
      return( YES);
   
   [_lock unlock];
   return( NO);
}


- (void) unlockWithCondition:(NSInteger)condition
{
   _currentCondition = condition;
   
   [_lock unlock];
}


- (BOOL) lockWhenCondition:(NSInteger) condition
                beforeDate:(NSDate *) limit
{
   if( ! [_lock lockBeforeDate:limit])
      return( NO);
   
   for(;;)
   {
      if( _currentCondition == condition)
         return( YES);
      
      [_lock lockBeforeDate:limit];  // or hopefully earlier
   }
}


#pragma mark -
#pragma mark NSLocking

- (void *) forward:(void *) param
{
   // everything we don't implement, forward to the lock
   return( mulle_objc_object_call( _lock, _cmd, param));
}

@end


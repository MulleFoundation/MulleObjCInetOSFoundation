/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSConditionLock.h is a part of MulleFoundation
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


@interface NSConditionLock : NSObject <NSLocking>
{
   NSLock      *_lock;
   NSInteger   _currentCondition;
}

@property( copy) NSString  *name;

- (instancetype) initWithCondition:(NSInteger) condition;

- (NSInteger) condition;

- (void) lockWhenCondition:(NSInteger)condition;
- (BOOL) tryLockWhenCondition:(NSInteger) condition;
- (void) unlockWithCondition:(NSInteger)condition;

- (BOOL) lockBeforeDate:(NSDate *)limit;
- (BOOL) lockWhenCondition:(NSInteger) condition
                beforeDate:(NSDate *) limit;

- (BOOL) tryLock;

@end


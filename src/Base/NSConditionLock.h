/*
 *  MulleFoundation - the mulle-objc class library
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
#import "dependencies.h"


@interface NSConditionLock : NSObject <NSLocking>
{
   NSLock      *_lock;
   NSInteger   _currentCondition;
}

@property( copy) NSString  *name;

- (instancetype) initWithCondition:(NSInteger) condition;

- (NSInteger) condition;

- (void) lockWhenCondition:(NSInteger) condition;
- (BOOL) tryLockWhenCondition:(NSInteger) condition;
- (void) unlockWithCondition:(NSInteger)condition;

- (BOOL) lockWhenCondition:(NSInteger) condition
                beforeDate:(NSDate *) limit;


@end


@interface NSConditionLock( Forwarded)

- (BOOL) tryLock;
- (BOOL) lockBeforeDate:(NSDate *) limit;

@end

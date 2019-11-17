/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSCondition.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"

//
// This is the basis for NSConditionLock. On its own its just a thin wrapper
// around pthreads
//
@interface NSCondition : NSObject < NSLocking>

@property( copy) NSString  *name;

- (void) signal;
- (void) broadcast;

// these two can supriously return even if the condition was signaled
- (void) wait;

// this is a BOOL: if you get NO, you know that limit has been reached
//
- (BOOL) waitUntilDate:(NSDate *) limit;

@end


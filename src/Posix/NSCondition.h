/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import <MulleObjCFoundation/MulleObjCFoundation.h>


@interface NSCondition : NSObject <NSLocking>
{
   pthread_mutex_t   _lock;
   pthread_cond_t    _condition;
}

@property( copy) NSString  *name;


- (void) signal;
- (void) broadcast;
- (void) wait;
- (BOOL) waitUntilDate:(NSDate *) limit;

@end


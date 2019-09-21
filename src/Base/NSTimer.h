/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTimer.h is a part of MulleFoundation
 *
 *  Copyright (C)  2019 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


@interface NSTimer : NSObject
{
   NSTimeInterval   _fireTimeInterval;
   NSTimeInterval   _repeatInterval;
   union
   {
      id             target;
      NSInvocation   *invocation;
   } _o;
   SEL               _selector;  // if 0: use _target as _invocation
   id                _userInfo;
   BOOL              _passUserInfo;
}

+ (instancetype) timerWithTimeInterval:(NSTimeInterval) timeInterval
                            invocation:(NSInvocation *) invocation
                               repeats:(BOOL) repeats;

+ (instancetype) timerWithTimeInterval:(NSTimeInterval) timeInterval
                                target:(id) target
                              selector:(SEL) selector
                              userInfo:(id) userInfo
                               repeats:(BOOL) repeats;

- (instancetype) initWithFireDate:(NSDate *) date
                         interval:(NSTimeInterval) interval
                           target:(id) target
                         selector:(SEL) sel
                         userInfo:(id) userInfo
                          repeats:(BOOL) repeats;

- (void) fire;
- (NSDate *) fireDate;
- (NSTimeInterval) mulleFireTimeInterval;

- (void) setFireDate:(NSDate *) date;
- (NSTimeInterval) timeInterval;

- (id) target;
- (id) userInfo;
- (SEL) selector;
- (id) argument;
- (NSInvocation *) invocation;

- (void) mulleSetFiresWithUserInfoAsArgument:(BOOL) flag;
- (BOOL) mulleFiresWithUserInfoAsArgument;

@end


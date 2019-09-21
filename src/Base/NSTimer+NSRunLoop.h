/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTimer+NSRunLoop.h is a part of MulleFoundation
 *
 *  Copyright (C)  2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTimer.h"



@interface NSTimer( NSRunLoop)


+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                      target:(id) target
                                    selector:(SEL) selector
                                    userInfo:(id) userInfo
                                     repeats:(BOOL) repeats;

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                  invocation:(NSInvocation *) invocation
                                     repeats:(BOOL) repeats;

- (void) invalidate;

@end
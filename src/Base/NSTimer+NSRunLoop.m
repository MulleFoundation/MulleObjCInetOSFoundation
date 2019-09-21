/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTimer+NSRunLoop.m is a part of MulleFoundation
 *
 *  Copyright (C)  2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTimer+NSRunLoop.h"

#import "NSRunLoop.h"
#import "NSRunLoop-Private.h"


@implementation NSTimer( NSRunLoop)


+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                      target:(id) target
                                    selector:(SEL) selector
                                    userInfo:(id) userInfo
                                     repeats:(BOOL) repeats
{
   NSTimer   *timer;

   timer = [self timerWithTimeInterval:timeInterval
                                target:target
                              selector:selector
                              userInfo:userInfo
                               repeats:repeats];
   [[NSRunLoop currentRunLoop] addTimer:timer
                                forMode:NSDefaultRunLoopMode];
   return( timer);
}


+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                  invocation:(NSInvocation *) invocation
                                     repeats:(BOOL) repeats
{
   NSTimer   *timer;

   timer = [self timerWithTimeInterval:timeInterval
                            invocation:invocation
                               repeats:repeats];
   [[NSRunLoop currentRunLoop] addTimer:timer
                                forMode:NSDefaultRunLoopMode];
   return( timer);
}


// the whole NSTimer/NSRunLoop interface is strange and crappy
// there is no "removeTimer" on NSRunLoop but only this

- (void) invalidate
{
   [[NSRunLoop currentRunLoop] _removeTimer:self];
}

@end


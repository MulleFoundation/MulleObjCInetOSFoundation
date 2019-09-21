/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSObject+NSRunLoop.m is a part of MulleFoundation
 *
 *  Copyright (C)  2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSObject+NSRunLoop.h"

#import "import-private.h"

#import "NSRunLoop.h"
#import "NSRunLoop-Private.h"
#import "NSTimer.h"


@implementation NSObject( NSRunLoop)

- (void) performSelector:(SEL) selector
              withObject:(id) argument
              afterDelay:(NSTimeInterval) delay
                 inModes:(NSArray *) modes
{
   NSRunLoopMode   modeName;
   NSRunLoop       *runLoop;
   NSTimer         *timer;

   runLoop = [NSRunLoop currentRunLoop];
   for( modeName in modes)
   {
      timer = [NSTimer timerWithTimeInterval:delay
                                      target:self
                                    selector:selector
                                    userInfo:argument
                                     repeats:NO];
      [timer mulleSetFiresWithUserInfoAsArgument:YES];
      [runLoop addTimer:timer
                forMode:modeName];
   }
}


- (void) performSelector:(SEL) selector
              withObject:(id) argument
              afterDelay:(NSTimeInterval) delay
{
   NSTimer    *timer;
   NSRunLoop  *runLoop;

   timer = [NSTimer timerWithTimeInterval:delay
                                   target:self
                                 selector:selector
                                 userInfo:argument
                                  repeats:NO];
   [timer mulleSetFiresWithUserInfoAsArgument:YES];
   runLoop = [NSRunLoop currentRunLoop];
   [runLoop addTimer:timer
             forMode:NSDefaultRunLoopMode];
}


+ (void) cancelPreviousPerformRequestsWithTarget:(id) target
                                        selector:(SEL) selector
                                          object:(id) argument
{
   [[NSRunLoop currentRunLoop] _removeTimersWithTarget:target
                                              selector:selector
                                              argument:argument];

}


+ (void) cancelPreviousPerformRequestsWithTarget:(id) target
{
   [[NSRunLoop currentRunLoop] _removeTimersWithTarget:target];
}

@end

//
//  NSRunLoop.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 20.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCOSFoundationParents.h"


//
// basically a wrapper around select(2) in POSIX
//
@interface NSRunLoop : NSObject
{
   NSMapTable      *_modeTable;
   NSMapTable      *_fileHandleTable;
   NSMutableArray  *_readyHandles;
   NSString        *_currentMode;
}

+ (NSRunLoop *) currentRunLoop;
+ (NSRunLoop *) mainRunLoop;

- (NSString *) currentMode;

- (void) acceptInputForMode:(NSString *) mode
                 beforeDate:(NSDate *) limitDate;

- (void) run;
- (void) runUntilDate:(NSDate *) limitDate;
- (BOOL) runMode:(NSString *) mode
      beforeDate:(NSDate *) limitDate;

@end


//
// various guises for Timers really
//
@interface NSRunLoop ( TimerFuture)

- (void) performSelector:(SEL) aSelector
              withObject:(id) anArgument
              afterDelay:(NSTimeInterval) delay
                 inModes:(NSArray *) modes;

- (void) performSelector:(SEL) aSelector
              withObject:(id) anArgument
              afterDelay:(NSTimeInterval) delay;

+ (void) cancelPreviousPerformRequestsWithTarget:(id) aTarget
                                        selector:(SEL) aSelector
                                          object:(id) anArgument;
+ (void) cancelPreviousPerformRequestsWithTarget:(id) aTarget;

- (void) performSelector:(SEL) aSelector
                  target:(id) target
                argument:(id) arg
                   order:(NSUInteger) order
                   modes:(NSArray *) modes;

- (void) cancelPerformSelector:(SEL) aSelector
                        target:(id) target
                      argument:(id) arg;
- (void) cancelPerformSelectorsWithTarget:(id) target;

@end


@interface NSRunLoop( Future)

- (void) _acceptInputForMode:(NSString *) mode
                  beforeDate:(NSDate *) limitDate;
@end

extern NSString   *NSDefaultRunLoopMode;

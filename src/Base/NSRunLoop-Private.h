//
//  NSRunLoop-Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 04.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#ifndef NSRunLoop_Private_h
#define NSRunLoop_Private_h


@class NSFileHandle;
@class NSTimer;


@protocol _NSFileDescriptor

- (int) fileDescriptor;
- (void) _notifyWithRunLoop:(NSRunLoop *) runloop;

@end


@interface NSRunLoop( Private)

- (void) _addObject:(NSObject <_NSFileDescriptor> *) handle
            forMode:(NSRunLoopMode) mode;
- (void) _fireTimersOfRunLoopMode:(struct MulleRunLoopMode *) mode
                     timeInterval:(NSTimeInterval) timeInterval;
- (void) _removeTimer:(NSTimer *) timer;
- (void) _removeTimersWithTarget:(id) target;
- (void) _removeTimersWithTarget:(id) target
                        selector:(SEL) sel
                        argument:(id) argument;
- (void) _sendMessagesOfRunLoopMode:(struct MulleRunLoopMode *) mode;
- (void) _acceptInputForRunLoopMode:(struct MulleRunLoopMode *) mode
                         beforeDate:(NSDate *) date;

- (NSTimer *) _firstTimerToFireOfRunLoopMode:(struct MulleRunLoopMode *) mode;

- (struct MulleRunLoopMode *) mulleRunLoopModeForMode:(NSRunLoopMode) modeName;

- (NSArray *) _modes;

@end


#endif /* NSRunLoop_Private_h */

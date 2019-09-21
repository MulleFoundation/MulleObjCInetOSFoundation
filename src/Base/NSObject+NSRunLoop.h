/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSObject+NSRunLoop.h is a part of MulleFoundation
 *
 *  Copyright (C)  2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
 #import "import.h"


@interface NSObject( NSRunLoop)

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


@end

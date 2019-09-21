/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTimer.m is a part of MulleFoundation
 *
 *  Copyright (C) 2019 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */

#import "NSTimer.h"

#import "import-private.h"



@implementation NSTimer

- (instancetype) _initWithFireTimeInterval:(NSTimeInterval) timeInterval
                            repeatInterval:(NSTimeInterval) repeatInterval
                                invocation:(NSInvocation *) invocation
{
   NSParameterAssert( timeInterval);
   NSParameterAssert( invocation);

   self->_fireTimeInterval = timeInterval;
   self->_repeatInterval   = repeatInterval;
   self->_o.invocation     = [invocation retain];

   return( self);
}


- (instancetype) _initWithFireTimeInterval:(NSTimeInterval) timeInterval
                            repeatInterval:(NSTimeInterval) repeatInterval
                                    target:(id) target
                                  selector:(SEL) sel
                                  userInfo:(id) userInfo
{
   NSParameterAssert( timeInterval);
   NSParameterAssert( target);
   NSParameterAssert( sel);

   self->_fireTimeInterval = timeInterval;
   self->_repeatInterval   = repeatInterval;
   self->_selector         = sel;
   self->_userInfo         = [userInfo retain];
   self->_o.target         = [target retain];

   return( self);
}


- (instancetype) initWithFireDate:(NSDate *) date
                         interval:(NSTimeInterval) repeatInterval
                           target:(id) target
                         selector:(SEL) selector
                         userInfo:(id) userInfo
                          repeats:(BOOL) repeats
{
   NSTimeInterval   fireTimeInterval;

   if( ! target || ! selector)
      return( nil);

   if( ! repeats)
      repeatInterval = 0.0;
   else
      if( repeatInterval < 0.0)
         repeatInterval = 0.1;

   fireTimeInterval = [date timeIntervalSinceReferenceDate];
   return( [self _initWithFireTimeInterval:fireTimeInterval
                            repeatInterval:repeatInterval
                                    target:target
                                  selector:selector
                                  userInfo:userInfo]);
}


- (void) dealloc
{
   [self->_o.target release];
   [self->_userInfo release];
   [super dealloc];
}

/*
 *
 */
+ (instancetype) timerWithTimeInterval:(NSTimeInterval) timeInterval
                            invocation:(NSInvocation *) invocation
                               repeats:(BOOL) repeats
{
   NSTimeInterval   fireTimeInterval;

   if( ! invocation)
      return( nil);

   if( timeInterval < 0.0)
      timeInterval = 0.1;

   fireTimeInterval = [NSDate timeIntervalSinceReferenceDate] + timeInterval;
   if( ! repeats)
      timeInterval = 0.0;
   return( [[[self alloc] _initWithFireTimeInterval:fireTimeInterval
                                     repeatInterval:timeInterval
                                         invocation:invocation] autorelease]);
}


+ (instancetype) timerWithTimeInterval:(NSTimeInterval) timeInterval
                                target:(id) target
                              selector:(SEL) selector
                              userInfo:(id) userInfo
                               repeats:(BOOL) repeats
{
   NSTimeInterval   fireTimeInterval;

   if( ! target || ! selector)
      return( nil);

   if( timeInterval < 0.0)
      timeInterval = 0.1;

   fireTimeInterval = [NSDate timeIntervalSinceReferenceDate] + timeInterval;
   if( ! repeats)
      timeInterval = 0.0;
   return( [[[self alloc] _initWithFireTimeInterval:fireTimeInterval
                                     repeatInterval:timeInterval
                                             target:target
                                           selector:selector
                                           userInfo:userInfo] autorelease]);
}


- (void) fire
{
   id   argument;

   if( self->_selector)
   {
      argument = _passUserInfo ? _userInfo : self;
      MulleObjCPerformSelector( self->_o.target, self->_selector, argument);
      return;
   }

   [self->_o.invocation invoke];
}


- (NSDate *) fireDate
{
   return( [NSDate dateWithTimeIntervalSinceReferenceDate:_fireTimeInterval]);
}


- (void) setFireDate:(NSDate *) date
{
   _fireTimeInterval = [date timeIntervalSinceReferenceDate];
}


- (NSTimeInterval) timeInterval
{
   return( _repeatInterval);
}


- (NSTimeInterval) mulleFireTimeInterval
{
   return( _fireTimeInterval);
}

- (void) mulleSetFiresWithUserInfoAsArgument:(BOOL) flag;
{
   _passUserInfo = flag;
}


- (BOOL) mulleFiresWithUserInfoAsArgument
{
   return( _passUserInfo);
}


- (id) target
{
   return( _selector ? _o.target : nil);
}


- (id) argument
{
   return( _passUserInfo ? _userInfo : nil);
}


- (id) userInfo
{
   return( _passUserInfo ? nil : _userInfo);
}


- (SEL) selector;
{
   return( _selector);
}


- (NSInvocation *) invocation
{
   return( _selector ? nil : _o.invocation);
}


@end

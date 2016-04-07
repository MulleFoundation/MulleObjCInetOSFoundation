/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSTimeZone.m is a part of MulleFoundation
 *
 *  Copyright (C)  2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTimeZone.h"


@interface _NSLocalTimeZone : NSTimeZone
{
}
@end


@implementation _NSLocalTimeZone

- (NSMethodSignature *) methodSignatureForSelector:(SEL) aSelector
{
   return( [super methodSignatureForSelector:@selector( self)]);
}


- (void) forwardInvocation:(NSInvocation *) anInvocation
{
   [anInvocation setTarget:[NSTimeZone defaultTimeZone]];
   [anInvocation invoke];
}


@end


@implementation NSTimeZone


+ (id) timeZoneWithName:(NSString *) name
{
   return( [[[self alloc] initWithName:name] autorelease]);
}
   
   
+ (id) timeZoneWithName:(NSString *) name 
                   data:(NSData *) data
{
   return( [[[self alloc] initWithName:name
                                  data:data] autorelease]);
}                   


- (id) initWithName:(NSString *) name 
               data:(NSData *) data;
{
   [self init];
   
   name_ = [name copy];
   data_ = [data_ copy];
   
   return( self);
}


+ (id) timeZoneWithAbbreviation:(NSString *) key
{
   NSString  *name;
   
   name = [[self abbreviationDictionary] objectForKey:key];
   if( ! name)
      return( nil);
      
   return( [self timeZoneWithName:name]);
}


- (NSString *) name
{
   return( name_);
}


- (NSData *) data
{
   return( data_);
}


static NSTimeZone   *systemTimeZone;
static NSTimeZone   *defaultTimeZone;


+ (NSTimeZone *) systemTimeZone
{
   if( ! systemTimeZone)
      systemTimeZone = [[self _uncachedSystemTimeZone] retain];
   return( systemTimeZone);
}


+ (void) resetSystemTimeZone
{
   [systemTimeZone autorelease];
   systemTimeZone = nil;
}


+ (NSTimeZone *) defaultTimeZone
{
   if( defaultTimeZone)
      return( defaultTimeZone);
   return( [self systemTimeZone]);
}


+ (void) setDefaultTimeZone:(NSTimeZone *) tz
{
   [defaultTimeZone autorelease];
   defaultTimeZone = [tz copy];
}


+ (NSTimeZone *) localTimeZone
{
   // return a proxy
   return( [[_NSLocalTimeZone new] autorelease]);
}


- (BOOL) isEqualToTimeZone:(NSTimeZone *) tz
{
   if( ! tz)
      return( NO);
   return( [data_ isEqualToData:[tz data]]);
}


@end

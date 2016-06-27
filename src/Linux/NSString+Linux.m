/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+Darwin.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSString( Linux)

// should probably query system locale or something

+ (NSStringEncoding) defaultCStringEncoding
{
   return( NSUTF8StringEncoding);
}


- (NSStringEncoding) defaultCStringEncoding
{
   return( NSUTF8StringEncoding);
}


+ (id) stringWithCString:(char *) s
{
   return( [[[self alloc] initWithCString:s] autorelease]);
}


+ (id) stringWithCString:(char *) s
                  length:(NSUInteger) len
{
   return( [[[self alloc] initWithCString:s
                                   length:len] autorelease]);
}


- (id) initWithCString:(char *) s
                length:(NSUInteger) len
{
   return( [self initWithBytes:s
                        length:len
                      encoding:[self defaultCStringEncoding]]);
}


- (id) initWithCString:(char *) s
{
   return( [self initWithBytes:s
                        length:strlen( s)
                      encoding:[self defaultCStringEncoding]]);
}


- (NSString *) _stringByRemovingPrivatePrefix
{
   return( self);
}


- (char *) cString
{
   return( (char *) [self UTF8String]);
}

@end

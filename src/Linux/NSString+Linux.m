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
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSString( Linux)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


// should probably query system locale or something

- (NSString *) _stringByRemovingPrivatePrefix
{
   return( self);
}


- (NSUInteger) cStringLength
{
   return( [self _UTF8StringLength]);
}


- (char *) cString
{
   return( (char *) [self UTF8String]);
}


- (NSStringEncoding) _cStringEncoding
{
   return( NSUTF8StringEncoding);
}


+ (NSStringEncoding) defaultCStringEncoding
{
   return( NSUTF8StringEncoding);
}

@end

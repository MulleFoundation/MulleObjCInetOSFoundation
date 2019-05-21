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
#define _DARWIN_C_SOURCE

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSString( Darwin)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


- (NSString *) _stringByRemovingPrivatePrefix
{
   if( [self hasPrefix:@"/private/"])
      if( [[NSFileManager defaultManager] fileExistsAtPath:self])
         return( [self substringFromIndex:8]);
   return( self);
}


- (NSUInteger) cStringLength
{
   return( [self mulleUTF8StringLength]);
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

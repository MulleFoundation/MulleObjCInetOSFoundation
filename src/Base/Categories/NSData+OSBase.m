/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSData+Posix.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSData+OSBase.h"

// other files in this library
#import "NSString+OSBase.h"
#import "NSLog.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSData( OSBase)

+ (instancetype) dataWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}



+ (instancetype) dataWithContentsOfFile:(NSString *) path
                                options:(NSUInteger) options
                                  error:(NSError **) error
{
   NSError   *dummy;
   NSData    *data;

   if( ! error)
      error = &dummy;
   *error = nil;

   data = [self dataWithContentsOfFile:path];
   if( ! data)
      *error = MulleObjCErrorGetCurrentError();
   return( data);
}


@end

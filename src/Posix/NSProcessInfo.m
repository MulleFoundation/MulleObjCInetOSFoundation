/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSProcessInfo.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700
 
#import "NSProcessInfo.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <unistd.h>


@implementation NSProcessInfo

+ (NSProcessInfo *) processInfo
{
   static id  processInfo;
   
   if( ! processInfo)
      processInfo = [self new];
   return( processInfo);
}

- (NSArray *) arguments
{
   return( _arguments);
}


- (NSDictionary *) environment
{
   return( _environment);
}


- (int) processIdentifier
{
   return( getpid());
}

@end


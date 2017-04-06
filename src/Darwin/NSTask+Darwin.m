/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask+Darwin.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#define _DARWIN_C_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <crt_externs.h>


@implementation NSTask( Darwin)

+ (SEL *) categoryDependencies
{
   static SEL   dependencies[] =
   {
      @selector( Posix),
      0
   };
   
   return( dependencies);
}


+ (char **) _environment
{
   return( *_NSGetEnviron());
}

@end

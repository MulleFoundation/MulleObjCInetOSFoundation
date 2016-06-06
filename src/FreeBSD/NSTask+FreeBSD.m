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
#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation




@implementation NSTask( FreeBSD)

+ (char **) _environment
{
   extern char  **environ;
   
   return( environ);
}

@end

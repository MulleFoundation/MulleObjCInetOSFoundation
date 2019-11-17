/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSCondition.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import-private.h"

#import "NSCondition.h"

// other files in this library

// std-c and dependencies


@implementation NSCondition

- (instancetype) init
{
   return( self);
}


- (void) dealloc
{
   [super dealloc];
}


- (void) signal
{
}


- (void) broadcast
{
}


- (void) wait
{
}



#pragma mark -
#pragma mark NSLocking

- (void) lock
{
}


- (void) unlock
{
}


- (BOOL) tryLock
{
   return( NO);
}


- (BOOL) waitUntilDate:(NSDate *) date
{
   return( NO);
}

@end


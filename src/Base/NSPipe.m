/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPipe.m is a part of MulleFoundation
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

#import "NSPipe.h"

// other files in this library
#import "NSFileHandle.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies

@implementation NSPipe

- (void) dealloc
{
   [_read release];
   [_write release];

   [super dealloc];
}


+ (instancetype) pipe
{
   return( [[[self alloc] init] autorelease]);
}


- (NSFileHandle *) fileHandleForReading
{
   return( _read);
}


- (NSFileHandle *) fileHandleForWriting
{
   return( _write);
}


- (int) _fileDescriptorForReading
{
   return( [_read fileDescriptor]);
}


- (int) _fileDescriptorForWriting
{
   return( [_write fileDescriptor]);
}

@end


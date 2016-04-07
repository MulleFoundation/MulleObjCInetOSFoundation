/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import "NSPipe.h"


@implementation NSPipe

static id    NSInitPipe( NSPipe *self)
{
   int   fds[ 2];
   
   if( pipe( fds))
      MulleObjCThrowErrnoException( "pipe creation");
      
   self->_read  = [[NSFileHandle alloc] initWithFileDescriptor:fds[ 0]
                                                             closeOnDealloc:YES];
   self->_write = [[NSFileHandle alloc] initWithFileDescriptor:fds[ 1]
                                                             closeOnDealloc:YES];
   
   return( self);
}


- (id) init
{
   return( NSInitPipe( self));
}


- (void) dealloc
{
   NSAutoreleaseObject( _read);
   NSAutoreleaseObject( _write);
   
   NSDeallocateObject( self);
}


+ (id) pipe
{
   return( NSAutoreleaseObject( NSInitPipe( NSAllocateObject( self, 0, NULL))));
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


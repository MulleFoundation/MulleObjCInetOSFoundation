//
//  NSPipe+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "MulleObjCOSBaseFoundation.h"

// other files in this library

// std-c and dependencies
#include <unistd.h>


@implementation NSPipe (Posix)

static id    NSInitPipe( NSPipe *self)
{
   int   fds[ 2];
   
   if( pipe( fds))
      MulleObjCThrowErrnoException( @"pipe creation");
   
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

@end

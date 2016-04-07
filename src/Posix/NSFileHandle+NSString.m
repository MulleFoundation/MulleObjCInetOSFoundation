/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSFileHandle+NSString.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSFileHandle+NSString.h"


// other files in this library

// other libraries of MulleObjCFoundation

// std-c and dependencies
#include <fcntl.h>


@implementation NSFileHandle( NSString)

static id  openFileInMode( Class self, NSString *path, int mode)
{
   char   *s;
   int    fd;
   
   s  = [path fileSystemRepresentation];
   fd = open( s, mode);
   if( fd == -1)
      return( nil);
   return( [[[self alloc] initWithFileDescriptor:fd
                  closeOnDealloc:YES] autorelease]);
}


+ (id) fileHandleForReadingAtPath:(NSString *) path
{
   return( openFileInMode( self, path, O_RDONLY));
}


+ (id) fileHandleForWritingAtPath:(NSString *) path
{
   return( openFileInMode( self, path, O_WRONLY));
}


+ (id) fileHandleForUpdatingAtPath:(NSString *) path
{
   return( openFileInMode( self, path, O_RDWR));
}

@end

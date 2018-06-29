/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPipe.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "dependencies.h"


@class NSFileHandle;


@interface NSPipe : NSObject
{
   NSFileHandle   *_read;
   NSFileHandle   *_write;
}

+ (instancetype) pipe;

- (NSFileHandle *) fileHandleForReading;
- (NSFileHandle *) fileHandleForWriting;

- (int) _fileDescriptorForReading;
- (int) _fileDescriptorForWriting;

@end


@interface NSPipe( Future)

- (instancetype) init;

@end

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
#import <MulleObjCFoundation/MulleObjCFoundation.h>


@class NSFileHandle;


@interface NSPipe : NSObject
{
   NSFileHandle   *_read;
   NSFileHandle   *_write;
}

- (id) init;
+ (id) pipe;

- (NSFileHandle *) fileHandleForReading;
- (NSFileHandle *) fileHandleForWriting;

- (int) _fileDescriptorForReading;
- (int) _fileDescriptorForWriting;

@end


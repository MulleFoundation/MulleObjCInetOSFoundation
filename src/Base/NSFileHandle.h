/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileHandle.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCOSFoundationParents.h"


@class NSData;

// this class contains the abstract code for a NSFileHandle
//
@interface NSFileHandle : NSObject
{
   void  *_fd;
   void  (*_closer)( int);
}

+ (id) fileHandleForReadingAtPath:(NSString *) path;
+ (id) fileHandleForWritingAtPath:(NSString *) path;
+ (id) fileHandleForUpdatingAtPath:(NSString *) path;

+ (id) fileHandleWithStandardError;
+ (id) fileHandleWithStandardInput;
+ (id) fileHandleWithStandardOutput;
+ (id) fileHandleWithNullDevice;

- (id) initWithFileDescriptor:(int) fd;
- (id) initWithFileDescriptor:(int) fd
               closeOnDealloc:(BOOL) flag;

- (NSData *) availableData;
- (NSData *) readDataToEndOfFile;
- (NSData *) readDataOfLength:(NSUInteger) length;

- (unsigned long long) offsetInFile;
- (void) seekToEndOfFile;
- (void) seekToFileOffset:(unsigned long long) offset;
- (void) closeFile;
- (void) synchronizeFile;
- (void) truncateFileAtOffset:(unsigned long long) offset;

- (void) writeData:(NSData *) data;

- (int) fileDescriptor;

- (int) _fileDescriptorForReading;
- (int) _fileDescriptorForWriting;

@end



// these enums are used internally for communicating with the
// subclasses, you don't need them otherwise

enum _MulleObjCOpenMode
{
   _MulleObjCOpenReadOnly  = 0,
   _MulleObjCOpenWriteOnly = 1,
   _MulleObjCOpenReadWrite = 2
};

enum _MulleObjCSeekMode
{
   _MulleObjCSeekCur = 0,
   _MulleObjCSeekSet = 1,
   _MulleObjCSeekEnd = 2
};

   
   
@interface NSFileHandle( Subclass)

+ (id) fileHandleWithStandardInput;
+ (id) fileHandleWithStandardOutput;
+ (id) fileHandleWithStandardError;

- (id) initWithFileDescriptor:(int) fd
               closeOnDealloc:(BOOL) flag;
- (void) closeFile;
- (void) synchronizeFile;


// low level stuff

+ (id) _fileHandleWithPath:(NSString *) path
                      mode:(enum _MulleObjCOpenMode) mode;

- (size_t) _readBytes:(void *) buf
                length:(size_t) len;

- (size_t) _writeBytes:(void *) buf
                length:(size_t) len;

- (off_t) _seek:(off_t) offset
           mode:(enum _MulleObjCSeekMode) mode;

@end





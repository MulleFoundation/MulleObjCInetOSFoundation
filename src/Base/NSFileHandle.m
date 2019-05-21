/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileHandle.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSFileHandle.h"

#import "NSPageAllocation.h"



@implementation NSNullDeviceFileHandle

- (int) fileDescriptor
{
   return( -1);
}


- (NSData *) availableData
{
   return( [NSData data]);
}


- (NSData *) readDataToEndOfFile
{
   return( [NSData data]);
}


- (NSData *) readDataOfLength:(NSUInteger) length
{
   return( [NSData data]);
}


- (unsigned long long) offsetInFile
{
   return( 0);
}


- (void) seekToEndOfFile
{
}


- (void) seekToFileOffset:(unsigned long long) offset
{
}


- (void) closeFile
{
}


- (void) synchronizeFile
{
}


- (void) truncateFileAtOffset:(unsigned long long) offset
{
}

@end


@implementation NSFileHandle


static void   nop( int fd)
{
}

#pragma mark - open

//
// keep fd in a void pointer, so that a subclass can
// use arbitrary large handles
//
static id  NSInitFileHandle( NSFileHandle *self, void *fd)
{
   self->_fd     = fd;
   self->_closer = nop;
   return( self);
}


- (instancetype) initWithFileDescriptor:(int) fd
{
   return( NSInitFileHandle( self, (void *) (intptr_t) fd));
}


+ (instancetype) fileHandleForReadingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenReadOnly]);
}


+ (instancetype) fileHandleForWritingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenWriteOnly]);
}


+ (instancetype) fileHandleForUpdatingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenReadWrite]);
}


+ (instancetype) fileHandleWithNullDevice
{
   return( [[NSNullDeviceFileHandle new] autorelease]);
}


- (void) finalize
{
   if( _closer)
      (*_closer)( (int) (intptr_t) _fd);
}


- (int) fileDescriptor
{
   return( (int) (intptr_t) _fd);
}


- (int) _fileDescriptorForReading
{
   return( (int) _fd);
}


- (int) _fileDescriptorForWriting
{
   return( (int) _fd);
}


#pragma mark - read

//
// if the returned [data length] is < length, then EOF has been reached
//
static NSData   *readDataOfLength( NSFileHandle *self, 
                                   NSUInteger length, 
                                   BOOL untilFullOrEOF)
{
   NSMutableData   *data;
   size_t          len;
   size_t          read_len;
   char            *buf;
   char            *start;

   if( ! length)
      return( nil);

   data  = [NSMutableData dataWithLength:length];
   start = [data mutableBytes];
   buf   = start;
   len   = length;

   do
   {
      read_len = [self _readBytes:buf
                           length:len];
      if( ! read_len)
         break;
      if( read_len == (size_t) -1)
         MulleObjCThrowErrnoException( @"read failed");

      len -= read_len;
      buf  = &buf[ read_len];
   }
   while( untilFullOrEOF && len);

   [data setLength:buf - start];
   return( data);
}


static NSData   *readAllData( NSFileHandle *self, BOOL untilFullOrEOF)
{
   NSMutableData   *data;
   NSData          *page;
   BOOL            eofReached;
   NSUInteger      length;

   length = NSPageSize();
   data   = [NSMutableData data];
   for(;;)
   {
      page = readDataOfLength( self, length, untilFullOrEOF);
      [data appendData:page];
      if( [page length] < length)
         return( data);
   }
}


- (NSData *) availableData
{
   return( readAllData( self, NO));
}


//
// it's obvious, that we need to do have a
// NSMutableData set is aware of pages
//
- (NSData *) readDataToEndOfFile
{
   return( readAllData( self, YES));
}


- (NSData *) readDataOfLength:(NSUInteger) length
{
   return( readDataOfLength( self, length, YES));
}


#pragma mark - write

- (void) writeData:(NSData *) data
{
   size_t   len;
   size_t   written;
   char     *buf;

   len = [data length];
   buf = [data bytes];
   do
   {
      written = [self _writeBytes:buf
                           length:len];
      len -= written;
      buf  = &buf[ written];

      // if written is 0, we should yield the thread
      // but actually doing a system call is pretty good also
      // i would assume (given ancient knowledge of OSes)
   }
   while( len);
}


#pragma mark - seek

- (unsigned long long) offsetInFile
{
   return( (unsigned long long) [self _seek:0
                                       mode:_MulleObjCSeekCur]);
}


- (void) seekToEndOfFile
{
   [self _seek:0
          mode:_MulleObjCSeekEnd];
}


- (void) seekToFileOffset:(unsigned long long) offset
{
   [self _seek:offset
          mode:_MulleObjCSeekSet];
}


- (void) truncateFileAtOffset:(unsigned long long) offset
{
   [self _seek:offset
          mode:_MulleObjCSeekCur]; // TODO: check!
}

@end


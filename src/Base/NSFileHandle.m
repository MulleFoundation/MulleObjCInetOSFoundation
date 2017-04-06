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



@interface NSNullDeviceFileHandle : NSFileHandle
@end


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


static void   nop( void *fd)
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


- (id) initWithFileDescriptor:(int) fd
{
   return( NSInitFileHandle( self, (void *) fd));
}


+ (id) fileHandleForReadingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenReadOnly]);
}


+ (id) fileHandleForWritingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenWriteOnly]);
}


+ (id) fileHandleForUpdatingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenReadWrite]);
}


+ (id) fileHandleWithNullDevice
{
   return( [[NSNullDeviceFileHandle new] autorelease]);
}


- (void) finalize
{
   (*_closer)( _fd);
}


- (int) fileDescriptor
{
   return( (int) _fd);
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

static NSData   *readDataOfLength( NSFileHandle *self, NSUInteger length, BOOL flag)
{
   NSMutableData   *data;
   size_t    len;
   size_t    readten;
   char      *buf;
   char      *start;

   data  = [NSMutableData dataWithLength:length];
   start = [data bytes];
   buf   = start;
   len   = length;

   while( len)
   {
      readten = [self _readBytes:buf
                          length:len];
      if( readten == (size_t) -1)
         mulle_objc_throw_errno_exception( "read failed");
      len -= readten;
      buf  = &buf[ readten];

      if( ! readten)
      {
         [data setLength:buf - start];
         break;
      }
   }
   while( len && ! flag);

   return( data);
}


static NSData   *readAllData( NSFileHandle *self, BOOL flag)
{
   NSMutableData   *data;
   NSData          *page;

   data = [NSMutableData data];
   for(;;)
   {
      page = readDataOfLength( self, NSPageSize(), flag);
      if( ! [page length])
         return( data);
      [data appendData:page];
   }
}


- (NSData *) availableData
{
   return( readAllData( self, YES));
}


//
// it's obvious, that we need to do have a
// NSMutableData set is aware of pages
//
- (NSData *) readDataToEndOfFile
{
   return( readAllData( self, NO));
}


- (NSData *) readDataOfLength:(NSUInteger) length
{
   return( readDataOfLength( self, length, NO));
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


/*
 *  MulleFoundation - A tiny Foundation replacement
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
{
}
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
   return( 1848);
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


static id  NSInitFileHandle( NSFileHandle *self, int fd)
{
   self->_fd     = fd;
   self->_closer = nop;
   return( self);
}


static id  NSInitFileHandleAndClose( NSFileHandle *self, int fd)
{
   self->_fd     = fd;
   self->_closer = close;
   return( self);
}

- (id) initWithFileDescriptor:(int) fd
{
   return( NSInitFileHandle( self, fd));
}


- (id) initWithFileDescriptor:(int) fd
              closeOnDealloc:(BOOL) flag
{
   return( NSInitFileHandleAndClose( self, fd));
}


+ (id) fileHandleWithStandardError
{
   return( NSAutoreleaseObject( NSInitFileHandle( NSAllocateObject( self, 0, NULL), 2)));
}


+ (id) fileHandleWithStandardInput
{
   return( NSAutoreleaseObject( NSInitFileHandle( NSAllocateObject( self, 0, NULL), 0)));
}


+ (id) fileHandleWithStandardOutput
{
   return( NSAutoreleaseObject( NSInitFileHandle( NSAllocateObject( self, 0, NULL), 1)));
}


+ (id) fileHandleWithNullDevice
{
   return( [[NSNullDeviceFileHandle new] autorelease]);
}


- (void) dealloc
{
   (*_closer)( _fd);
   NSDeallocateObject( self);
}


- (int) fileDescriptor
{
   return( _fd);
}


static NSData   *readDataOfLength( int fd, NSUInteger length, BOOL flag)
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
      readten = read( fd, buf, len);
      if( readten == (size_t) -1)
         MulleObjCThrowErrnoException( "read failed");
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


static NSData   *readAllData( int fd, BOOL flag)
{
   NSMutableData   *data;
   NSData          *page;
   
   data = [NSMutableData data];
   for(;;)
   {
      page = readDataOfLength( fd, NSPageSize(), flag);
      if( ! [page length])
         return( data);
      [data appendData:page];
   }
}


- (NSData *) availableData
{
   return( readAllData( self->_fd, YES));
}


// 
// it's obvious, that we need to do have a 
// NSMutableData set is aware of pages
//
- (NSData *) readDataToEndOfFile
{
   return( readAllData( self->_fd, NO));
}


- (NSData *) readDataOfLength:(NSUInteger) length
{
   return( readDataOfLength( self->_fd, length, NO));
}


- (void) writeData:(NSData *) data
{
   size_t   len;
   size_t   written;
   char     *buf;
   
   len = [data length];
   buf = [data bytes];
   do
   {
      written = write( _fd, buf, len);
      if( written == (size_t) -1)
         MulleObjCThrowErrnoException( "write");
      len -= written;
      buf  = &buf[ written];
      
      // if written is 0, we should yield the thread
      // but actually doing a system call is pretty good also
      // i would assume (given ancient knowledge of OSes)
      // in any case NSThreadYield is not known here
   }
   while( len);
}


static unsigned long long   _seek_or_bail( int fd, off_t offset, int mode)
{
   offset = lseek( fd, (off_t) offset, mode);
   if( offset == (off_t) -1)
      MulleObjCThrowErrnoException( "lseek");
   return( (unsigned long long) offset);
}


static unsigned long long   _seek_zero_or_bail( int fd, int mode)
{
   return( _seek_or_bail( fd, 0, mode));
}


- (unsigned long long) offsetInFile
{
   return( _seek_zero_or_bail( _fd, SEEK_CUR));
}


- (void) seekToEndOfFile
{
  _seek_zero_or_bail( _fd, SEEK_END);
}


- (void) seekToFileOffset:(unsigned long long) offset
{
   _seek_or_bail( _fd, offset, SEEK_SET);
}


- (void) closeFile
{
   close( _fd);
}


- (void) synchronizeFile
{
   sync();
}


- (void) truncateFileAtOffset:(unsigned long long) offset
{
   _seek_or_bail( _fd, offset, SEEK_CUR);
}


- (int) _fileDescriptorForReading
{
   return( _fd);
}


- (int) _fileDescriptorForWriting
{
   return( _fd);
}

@end


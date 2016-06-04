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
// define, that make things POSIXly
#define _XOPEN_SOURCE 700
 
#import "NSFileHandle.h"

// other files in this library
#import "NSString+Posix.h"
#import "NSString+PosixPathHandling.h"

// other libraries of MulleObjCFoundation

// std-c and dependencies
#include <fcntl.h>


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
   self->_closer = (void *) close;
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


- (void) finalize
{
   (*_closer)( _fd);
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
         mulle_objc_throw_errno_exception( "write");
      len -= written;
      buf  = &buf[ written];
      
      // if written is 0, we should yield the thread
      // but actually doing a system call is pretty good also
      // i would assume (given ancient knowledge of OSes)
   }
   while( len);
}


static unsigned long long   _seek_or_bail( int fd, off_t offset, int mode)
{
   offset = lseek( fd, (off_t) offset, mode);
   if( offset == (off_t) -1)
      mulle_objc_throw_errno_exception( "lseek");
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


#pragma mark -
#pragma mark path


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


/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  MulleObjCBufferedOutputStream.h is a part of MulleFoundation
 *
 *  Copyright (C) 2009 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCBufferedInputStream.h"

// other files in this library
#import "MulleObjCBufferedInputStream+InlineAccessors.h"

// std-c and dependencies


static void   MulleObjCBufferedInputStreamFillBuffer( MulleObjCBufferedInputStream *self);
#define       MulleObjCBufferedInputStreamDefaultBufferSize  0x1000


@implementation MulleObjCBufferedInputStream

- (id) initWithInputStream:(id <MulleObjCInputStream>) stream
{
   _stream = [stream retain];
   MulleObjCBufferedInputStreamFillBuffer( self);  // need to have a notion of "_current" immediately
   
   if( self->_current == self->_sentinel)           // we can't have nothing
   {
      [self autorelease];
      return( nil);
   }
   
   return( self);
}


- (id) initWithData:(NSData *) data
{
   MulleObjCMemoryInputStream  *stream;
   
   stream = [[[MulleObjCMemoryInputStream alloc] initWithData:data] autorelease];
   return( [self initWithInputStream:stream]);
}


- (void) dealloc
{
   [_stream release];
   [_data release];

   [super dealloc];
}


- (NSData *) readDataOfLength:(NSUInteger) size
{
   id           data;
   NSUInteger   available;
   
   available = MulleObjCBufferedInputStreamBytesAvailable( self);
   
   if( size >= available)
   {
      data = [NSData dataWithBytes:_current
                            length:size];
      _current += size;
      return( data);
   }
   
   if( ! available && size >= MulleObjCBufferedInputStreamDefaultBufferSize / 2)
      return( [_stream readDataOfLength:size]);
      
   data = [NSMutableData dataWithCapacity:size];
   [data appendBytes:_current
              length:available];
   _current += available;

   // 
   if( size >= MulleObjCBufferedInputStreamDefaultBufferSize)
   {
      [data appendData:[_stream readDataOfLength:size]];
      return( data);
   }
   
   MulleObjCBufferedInputStreamFillBuffer( self);
   available = MulleObjCBufferedInputStreamBytesAvailable( self);
   
   if( size >= available)
      size = available;
      
   [data appendBytes:_current
              length:size];
   _current += size;
   return( data);
}


- (void) bookmark
{
   NSParameterAssert( self->_current);
   
   MulleObjCBufferedInputStreamBookmark( self);
}


struct MulleObjCMemoryRegion   MulleObjCBufferedInputStreamBookmarkedRegion( MulleObjCBufferedInputStream *self)
{
   struct MulleObjCMemoryRegion  region;
   NSMutableData                 *bookmarkData;
   unsigned char                 *start;
   long                          length;
   
   NSCParameterAssert( [self isKindOfClass:[MulleObjCBufferedInputStream class]]);

   if( ! self->_bookmark)
   {
      region.bytes  = NULL;
      region.length = 0;
      return( region);
   }
      
   if( self->_bookmarkData)
   {
      bookmarkData        = [self->_bookmarkData autorelease];
      self->_bookmarkData = nil;
   
      start  = (unsigned char *) [self->_data bytes];
      length = (long) (self->_current - start);
      if( length)
         [bookmarkData appendBytes:start
                            length:length];

      region.bytes  = (unsigned char *) [bookmarkData bytes];
      region.length = [bookmarkData length];
   }
   else
   {
      region.bytes  = self->_bookmark;
      region.length = (long) (self->_current - self->_bookmark);
   }
   self->_bookmark = NULL;
   return( region);
}


- (struct MulleObjCMemoryRegion) bookmarkedRegion
{
   return( MulleObjCBufferedInputStreamBookmarkedRegion( self));
}


- (NSData *) bookmarkedData
{
   NSMutableData   *data;
   unsigned char   *start;
   long            length;
   
   if( ! _bookmark)
      return( nil);
      
   if( _bookmarkData)
   {
      data = [_bookmarkData autorelease];
      _bookmarkData = nil;
      _bookmark     = NULL;
   
      start  = (unsigned char *) [_data bytes];
      length = (long) (self->_current - start);
      if( length)
         [data appendBytes:start
                  length:length];
      return( data);
   }

   length    = (long) (self->_current - self->_bookmark);
   _bookmark = NULL;
   
   if( length)
      return( [[[NSData alloc] initWithBytes:self->_bookmark
                                     length:length] autorelease]);
   return( nil);
}


int   MulleObjCBufferedInputStreamFillBufferAndNextCharacter( MulleObjCBufferedInputStream *self)
{
   NSCParameterAssert( [self isKindOfClass:[MulleObjCBufferedInputStream class]]);

   MulleObjCBufferedInputStreamFillBuffer( self);
   if( self->_current == self->_sentinel)
      return( -1);
   return( *self->_current);
}


static void   MulleObjCBufferedInputStreamFillBuffer( MulleObjCBufferedInputStream *self)
{
   NSCParameterAssert( [self isKindOfClass:[MulleObjCBufferedInputStream class]]);
   NSCParameterAssert( self->_current == self->_sentinel);
   
   //
   // we need to preserve Bookmark data, when we change the buffer
   //
   if( self->_bookmark)
   {
      if( ! self->_bookmarkData)
         self->_bookmarkData = [[NSMutableData alloc] initWithBytes:self->_bookmark
                                                             length:self->_sentinel - self->_bookmark];
      else
         [self->_bookmarkData  appendData:self->_data];
   }
   
   [self->_data release];
  
   self->_data     = [[self->_stream readDataOfLength:MulleObjCBufferedInputStreamDefaultBufferSize] retain];
   self->_current  = (void *) [self->_data bytes];
   self->_sentinel = &self->_current[ [self->_data length]];
}

@end


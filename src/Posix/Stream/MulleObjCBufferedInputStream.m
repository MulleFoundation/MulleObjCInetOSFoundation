/*
 *  MulleFoundation - A tiny Foundation replacement
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

#import "MulleObjCBufferedInputStream+InlineAccessors.h"



static void   MulleObjCBufferedInputStreamFillBuffer( MulleObjCBufferedInputStream *self);
#define       MulleObjCBufferedInputStreamDefaultBufferSize  0x1000


@implementation MulleObjCBufferedInputStream

- (id) initWithInputStream:(id <MulleObjCInputStream>) stream
{
   stream_ = [stream retain];
   MulleObjCBufferedInputStreamFillBuffer( self);  // need to have a notion of "current_" immediately
   
   if( self->current_ == self->sentinel_)           // we can't have nothing
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
   [stream_ release];
   [data_ release];

   [super dealloc];
}


- (NSData *) readDataOfLength:(NSUInteger) size
{
   id           data;
   NSUInteger   available;
   
   available = MulleObjCBufferedInputStreamBytesAvailable( self);
   
   if( size >= available)
   {
      data = [NSData dataWithBytes:current_
                            length:size];
      current_ += size;
      return( data);
   }
   
   if( ! available && size >= MulleObjCBufferedInputStreamDefaultBufferSize / 2)
      return( [stream_ readDataOfLength:size]);
      
   data = [NSMutableData dataWithCapacity:size];
   [data appendBytes:current_
              length:available];
   current_ += available;

   // 
   if( size >= MulleObjCBufferedInputStreamDefaultBufferSize)
   {
      [data appendData:[stream_ readDataOfLength:size]];
      return( data);
   }
   
   MulleObjCBufferedInputStreamFillBuffer( self);
   available = MulleObjCBufferedInputStreamBytesAvailable( self);
   
   if( size >= available)
      size = available;
      
   [data appendBytes:current_
              length:size];
   current_ += size;
   return( data);
}


- (void) bookmark
{
   NSParameterAssert( self->current_);
   
   MulleObjCBufferedInputStreamBookmark( self);
}


struct MulleObjCMemoryRegion   MulleObjCBufferedInputStreamBookmarkedRegion( MulleObjCBufferedInputStream *self)
{
   struct MulleObjCMemoryRegion  region;
   NSMutableData                 *bookmarkData;
   unsigned char                 *start;
   long                          length;
   
   NSCParameterAssert( [self isKindOfClass:[MulleObjCBufferedInputStream class]]);

   if( ! self->bookmark_)
   {
      region.bytes  = NULL;
      region.length = 0;
      return( region);
   }
      
   if( self->bookmarkData_)
   {
      bookmarkData        = [self->bookmarkData_ autorelease];
      self->bookmarkData_ = nil;
   
      start  = (unsigned char *) [self->data_ bytes];
      length = (long) (self->current_ - start);
      if( length)
         [bookmarkData appendBytes:start
                            length:length];

      region.bytes  = (unsigned char *) [bookmarkData bytes];
      region.length = [bookmarkData length];
   }
   else
   {
      region.bytes  = self->bookmark_;
      region.length = (long) (self->current_ - self->bookmark_);
   }
   self->bookmark_ = NULL;
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
   
   if( ! bookmark_)
      return( nil);
      
   if( bookmarkData_)
   {
      data = [bookmarkData_ autorelease];
      bookmarkData_ = nil;
      bookmark_     = NULL;
   
      start  = (unsigned char *) [data_ bytes];
      length = (long) (self->current_ - start);
      if( length)
         [data appendBytes:start
                  length:length];
      return( data);
   }

   length    = (long) (self->current_ - self->bookmark_);
   bookmark_ = NULL;
   
   if( length)
      return( [[[NSData alloc] initWithBytes:self->bookmark_
                                     length:length] autorelease]);
   return( nil);
}


int   MulleObjCBufferedInputStreamFillBufferAndNextCharacter( MulleObjCBufferedInputStream *self)
{
   NSCParameterAssert( [self isKindOfClass:[MulleObjCBufferedInputStream class]]);

   MulleObjCBufferedInputStreamFillBuffer( self);
   if( self->current_ == self->sentinel_)
      return( -1);
   return( *self->current_);
}


static void   MulleObjCBufferedInputStreamFillBuffer( MulleObjCBufferedInputStream *self)
{
   NSCParameterAssert( [self isKindOfClass:[MulleObjCBufferedInputStream class]]);
   NSCParameterAssert( self->current_ == self->sentinel_);
   
   //
   // we need to preserve Bookmark data, when we change the buffer
   //
   if( self->bookmark_)
   {
      if( ! self->bookmarkData_)
         self->bookmarkData_ = [[NSMutableData alloc] initWithBytes:self->bookmark_
                                                             length:self->sentinel_ - self->bookmark_];
      else
         [self->bookmarkData_  appendData:self->data_];
   }
   
   [self->data_ release];
  
   self->data_     = [[self->stream_ readDataOfLength:MulleObjCBufferedInputStreamDefaultBufferSize] retain];
   self->current_  = (void *) [self->data_ bytes];
   self->sentinel_ = &self->current_[ [self->data_ length]];
}

@end


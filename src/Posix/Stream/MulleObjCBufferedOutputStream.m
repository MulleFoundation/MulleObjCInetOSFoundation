/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  MulleObjCBufferedOutputStream.m is a part of MulleFoundation
 *
 *  Copyright (C) 2009 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */

#import "MulleObjCBufferedOutputStream.h"


@implementation MulleObjCBufferedOutputStream

#define Buffersize      0x2000
#define MaxToBuffer     (Buffersize - (Buffersize / 4))

- (id) initWithOutputStream:(id <MulleObjCOutputStream>) stream
{
   stream_ = [stream retain];
   data_   = [[NSMutableData alloc] initWithLength:Buffersize];
   
   self->_start    = (unsigned char *) [data_ bytes];
   self->current_  = self->_start;
   self->sentinel_ = &self->current_[ Buffersize]; 

   return( self);
}


- (id) initWithMutableData:(NSMutableData *) data
{
   stream_ = [data retain];

   return( self);
}


- (void) flush
{
   NSData   *data;
   
   if( data_)
   {
      data = [[NSData alloc] initWithBytesNoCopy:self->_start
                                          length:self->current_ - self->_start
                                    freeWhenDone:NO];
      [stream_ writeData:data];
      [data release];
   }
   
   self->current_ = self->_start;
}


- (void) dealloc
{
   [self flush];

   [stream_ release];
   [data_ release];

   [super dealloc];
}


- (void) writeData:(NSData *) data
{
   size_t   len;
   
   len = [data length];
   if( data_ && len < MaxToBuffer)
   {
      if( &self->current_[ len] >= self->sentinel_)
         [self flush];
         
      memcpy( self->current_, [data bytes], len);
      self->current_ += len;
      return;
   }
   [stream_ writeData:data];
}



void   MulleObjCBufferedOutputStreamExtendBuffer( MulleObjCBufferedOutputStream *self)
{
   NSCParameterAssert( self->current_ == self->sentinel_);

   [self flush];
}

@end

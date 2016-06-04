/*
 *  MulleFoundation - the mulle-objc class library
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

// other files in this library
#import "MulleObjCBufferedOutputStream+InlineAccessors.h"

// std-c and dependencies


@implementation MulleObjCBufferedOutputStream

#define Buffersize      0x2000
#define MaxToBuffer     (Buffersize - (Buffersize / 4))

- (id) initWithOutputStream:(id <MulleObjCOutputStream>) stream
{
   _stream = [stream retain];
   _data   = [[NSMutableData alloc] initWithLength:Buffersize];
   
   self->_start    = (unsigned char *) [_data bytes];
   self->_current  = self->_start;
   self->_sentinel = &self->_current[ Buffersize]; 

   return( self);
}


- (id) initWithMutableData:(NSMutableData *) data
{
   _stream = [data retain];

   return( self);
}


- (void) flush
{
   NSData   *data;
   
   if( _data)
   {
      data = [[NSData alloc] initWithBytesNoCopy:self->_start
                                          length:self->_current - self->_start
                                    freeWhenDone:NO];
      [_stream writeData:data];
      [data release];
   }
   
   self->_current = self->_start;
}


- (void) dealloc
{
   [self flush];

   [_stream release];
   [_data release];

   [super dealloc];
}


- (void) writeData:(NSData *) data
{
   size_t   len;
   
   len = [data length];
   if( _data && len < MaxToBuffer)
   {
      if( &self->_current[ len] >= self->_sentinel)
         [self flush];
         
      memcpy( self->_current, [data bytes], len);
      self->_current += len;
      return;
   }
   [_stream writeData:data];
}



void   MulleObjCBufferedOutputStreamExtendBuffer( MulleObjCBufferedOutputStream *self)
{
   NSCParameterAssert( self->_current == self->_sentinel);

   [self flush];
}

@end

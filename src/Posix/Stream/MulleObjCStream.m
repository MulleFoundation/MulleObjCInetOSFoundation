/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  _NSDataStream.h is a part of MulleFoundation
 *
 *  Copyright (C) 2009 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCStream.h"



@implementation MulleObjCMemoryInputStream

- (id) initWithData:(NSData *) data
{
   data_ = [data retain];
   return( self);
}


- (void) dealloc
{
   [data_ release];
   [super dealloc];
}


- (NSData *) readDataOfLength:(NSUInteger) length
{
   unsigned char   *dst;
   NSData          *data;
   
   if( ! current_)
   {
      current_  = (unsigned char *) [data_ bytes];
      sentinel_ = &current_[ [data_ length]];
   }
   
   //
   // if isa is NSMutableData and you changed something, then reading will
   // fail miserably. Could reimplement this in NSMutableData or so, to
   // use an integer index instead...
   //
   NSParameterAssert( current_ >= (unsigned char *) [data_ bytes]);
   NSParameterAssert( current_ <= &((unsigned char *)[data_ bytes])[ [data_ length]]);
   
   dst = &current_[ length];
   if( dst > sentinel_)
   {
      length -= (dst - sentinel_);
      dst     = sentinel_;
   }
   
   if( ! length)
      return( nil);
      
   data = [NSData dataWithBytes:current_
                         length:length];
   current_ = dst;
   return( data);
}

@end



@implementation NSMutableData( MulleObjCOutputStream)

- (void) writeData:(NSData *) data
{
   [self appendData:data];
}

@end


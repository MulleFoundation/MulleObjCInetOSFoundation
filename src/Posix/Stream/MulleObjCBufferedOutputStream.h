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

#import "MulleObjCStream.h"


@interface MulleObjCBufferedOutputStream : NSObject < MulleObjCOutputStream>
{
#ifdef _NS_BUFFERED_DATA_OUTPUT_STREAM_IVAR_VISIBILITY
_NS_BUFFERED_DATA_OUTPUT_STREAM_IVAR_VISIBILITY      // allow public access for internal use
#endif
   id <MulleObjCOutputStream >  stream_;
   
   NSMutableData   *data_;   
   unsigned char   *_start;
   unsigned char   *current_;
   unsigned char   *sentinel_; 
}

- (id) initWithOutputStream:(id <MulleObjCOutputStream>) stream;

- (void) writeData:(NSData *) data;

@end



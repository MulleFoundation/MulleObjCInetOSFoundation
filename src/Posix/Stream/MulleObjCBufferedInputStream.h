/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  MulleObjCBufferedInputStream.h is a part of MulleFoundation
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


//
// MulleObjCBufferedInputStream is an abstraction to be used if reading
// or writing to NSFilehandles
//
struct MulleObjCMemoryRegion
{
   unsigned char   *bytes;
   size_t          length;
};



@interface MulleObjCBufferedInputStream : NSObject < MulleObjCInputStream>
{
#ifdef _NS_BUFFERED_DATA_INPUT_STREAM_IVAR_VISIBILITY
_NS_BUFFERED_DATA_INPUT_STREAM_IVAR_VISIBILITY      // allow public access for internal use
#endif
   id <MulleObjCInputStream >  _stream;
   
   NSData          *_data;   
   unsigned char   *_current;
   unsigned char   *_sentinel; 
   
   unsigned char   *_bookmark; 
   NSMutableData   *_bookmarkData;
}

- (id) initWithData:(NSData *) data;
- (id) initWithInputStream:(id <MulleObjCInputStream>) stream;

- (NSData *) readDataOfLength:(NSUInteger) size;

// you can only set one bookmark
- (void) bookmark;

// this returns the bookmark and clears it. use bytes before getting next
// character...
- (struct MulleObjCMemoryRegion) bookmarkedRegion;   // usually better
- (NSData *) bookmarkedData;                         // use if you want a NSData anyway

@end





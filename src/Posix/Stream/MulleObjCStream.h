/*
 *  MulleFoundation - the mulle-objc class library
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
#import <MulleObjCFoundation/MulleObjCFoundation.h>


@protocol MulleObjCInputStream < NSObject>

- (NSData *) readDataOfLength:(NSUInteger) length;

@end


@protocol MulleObjCOutputStream  < NSObject>

- (void) writeData:(NSData *) data;

@end


@interface NSMutableData( MulleObjCOutputStream) < MulleObjCOutputStream >

- (void) writeData:(NSData *) data;

@end



//
// this is the only really interesting class, as we want to augment
// NSData to have a notion of current pointer
//
@interface MulleObjCMemoryInputStream : NSObject < MulleObjCInputStream >
{
   NSData          *_data;
   unsigned char   *_current;
   unsigned char   *_sentinel;
}

- (id) initWithData:(NSData *) data;
- (NSData *) readDataOfLength:(NSUInteger) length;

@end


// or just use NSMutableData
@interface MulleObjCMemoryOutputStream : NSMutableData < MulleObjCOutputStream >
@end




// make it known, that NSFileHandle nicely supports streams as is
//@interface NSFileHandle( MulleObjCOutputStream) < _NSInputDataStream, MulleObjCOutputStream >
//@end



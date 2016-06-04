/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  MulleObjCBufferedOutputStream+InlineAccessors.h is a part of MulleFoundation
 *
 *  Copyright (C) 2009 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */

#define _NS_BUFFERED_DATA_INPUT_STREAM_IVAR_VISIBILITY  @public
 
#import "MulleObjCBufferedInputStream.h"


// don't inline these and don't call'em yourself
int    MulleObjCBufferedInputStreamFillBufferAndNextCharacter( MulleObjCBufferedInputStream *self);
struct MulleObjCMemoryRegion   MulleObjCBufferedInputStreamBookmarkedRegion( MulleObjCBufferedInputStream *self);

// keep as small as possible for inlining
static inline int  MulleObjCBufferedInputStreamCurrentCharacter( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   
   if( ! self->_current)
      return( -1);
   return( *self->_current);
}


static inline int   MulleObjCBufferedInputStreamNextCharacter( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   
   assert( self->_current);

   if( ++self->_current == self->_sentinel)
      return( MulleObjCBufferedInputStreamFillBufferAndNextCharacter( _self));

   return( *self->_current);
}


static inline int   MulleObjCBufferedInputStreamConsumeCurrentCharacter( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   int     c;

   // end reached ?
   if( ! self->_current)
      return( -1);
   c = *self->_current;
   
   MulleObjCBufferedInputStreamNextCharacter( _self);
   return( c);
}


static inline size_t  MulleObjCBufferedInputStreamBytesAvailable( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   
   return( self->_sentinel - self->_current);
}


static inline void  MulleObjCBufferedInputStreamBookmark( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   
   if( self->_bookmarkData)
   {
      [self->_bookmarkData release];
      self->_bookmarkData = nil;
   }
   self->_bookmark = self->_current;
}


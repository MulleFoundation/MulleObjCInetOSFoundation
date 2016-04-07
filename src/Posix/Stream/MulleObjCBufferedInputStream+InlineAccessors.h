/*
 *  MulleFoundation - A tiny Foundation replacement
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
   
   if( ! self->current_)
      return( -1);
   return( *self->current_);
}


static inline int   MulleObjCBufferedInputStreamNextCharacter( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   
   assert( self->current_);

   if( ++self->current_ == self->sentinel_)
      return( MulleObjCBufferedInputStreamFillBufferAndNextCharacter( _self));

   return( *self->current_);
}


static inline int   MulleObjCBufferedInputStreamConsumeCurrentCharacter( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   int     c;

   // end reached ?
   if( ! self->current_)
      return( -1);
   c = *self->current_;
   
   MulleObjCBufferedInputStreamNextCharacter( _self);
   return( c);
}


static inline size_t  MulleObjCBufferedInputStreamBytesAvailable( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   
   return( self->sentinel_ - self->current_);
}


static inline void  MulleObjCBufferedInputStreamBookmark( MulleObjCBufferedInputStream *_self)
{
   struct { @defs( MulleObjCBufferedInputStream); }  *self = (void *) _self;
   
   if( self->bookmarkData_)
   {
      [self->bookmarkData_ release];
      self->bookmarkData_ = nil;
   }
   self->bookmark_ = self->current_;
}


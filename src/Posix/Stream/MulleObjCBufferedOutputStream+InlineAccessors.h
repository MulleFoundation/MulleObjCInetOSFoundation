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

#define _NS_BUFFERED_DATA_OUTPUT_STREAM_IVAR_VISIBILITY  @public
 
#import "MulleObjCBufferedOutputStream.h"


// don't inline these and don't call'em yourself
void   MulleObjCBufferedOutputStreamExtendBuffer( MulleObjCBufferedOutputStream *self);

// keep as small as possible for inlining
static inline void  MulleObjCBufferedOutputStreamNextCharacter( MulleObjCBufferedOutputStream *_self, char c)
{
   struct { @defs( MulleObjCBufferedOutputStream) }  *self = (void *) _self;
   
   if( self->_current == self->_sentinel)
      MulleObjCBufferedOutputStreamExtendBuffer( _self);
   *self->_current++ = c;
}



static inline size_t  MulleObjCBufferedOutputStreamBytesWritten( MulleObjCBufferedOutputStream *_self)
{
   struct { @defs( MulleObjCBufferedOutputStream) }  *self = (void *) _self;
   
   return( self->_current - self->_start);
}


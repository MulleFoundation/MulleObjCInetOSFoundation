/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  MulleObjCBufferedInputStream+NSFilehandle.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCBufferedOutputStream+NSFileHandle.h"


@implementation MulleObjCBufferedOutputStream( NSFileHandle)

- (id) initWithFileHandle:(NSFileHandle *) handle
{
   return( [self initWithOutputStream:handle]);
}

@end

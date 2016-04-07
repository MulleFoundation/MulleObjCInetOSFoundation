/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  MulleObjCBufferedInputStream+NSFilehandle.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCBufferedInputStream+NSFilehandle.h"


@implementation MulleObjCBufferedInputStream( NSFilehandle)

- (id) initWithFileHandle:(NSFileHandle *) handle
{
   return( [self initWithInputStream:handle]);
}

@end

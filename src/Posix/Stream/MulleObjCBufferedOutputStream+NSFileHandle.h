/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  MulleObjCBufferedOutputStream+NSFileHandle.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCBufferedOutputStream.h"

@class NSFileHandle;


@interface MulleObjCBufferedOutputStream( NSFilehandle)

- (id) initWithFileHandle:(NSFileHandle *) data;

@end

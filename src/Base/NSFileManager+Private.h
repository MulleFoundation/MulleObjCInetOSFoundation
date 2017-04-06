/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager+PosixPrivate.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSFileManager.h"

enum _MulleObjCFilenameType
{
   _MulleObjCFilenameIsNoFile = -1,
   _MulleObjCFilenameIsNormal = 0,
   _MulleObjCFilenameIsHidden = 1,
   _MulleObjCFilenameIsDot,
   _MulleObjCFilenameIsDotDot,
   _MulleObjCFilenameIsSystem
};


@interface NSFileManager( Private)

- (enum _MulleObjCFilenameType) _isValidDirectoryContentsFilenameAsCString:(char *) s;

@end

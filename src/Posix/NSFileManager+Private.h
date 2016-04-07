/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSFileManager+Private.h is a part of MulleFoundation
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


enum
{
   NSFileIsNoFile = -1,
   NSFileIsNormal = 0,
   NSFileIsHidden = 1,
   NSFileIsDot,
   NSFileIsDotDot,
   NSFileIsSystem 
};

@interface NSFileManager ( _Private)

+ (int) _isValidDirectoryContentsFilenameAsCString:(char *) s;

@end

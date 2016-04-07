/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSFileHandle+NSString.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSFileHandle.h"


@class NSString;


@interface NSFileHandle( NSString)

+ (id) fileHandleForReadingAtPath:(NSString *) path;
+ (id) fileHandleForWritingAtPath:(NSString *) path;
+ (id) fileHandleForUpdatingAtPath:(NSString *) path;

@end

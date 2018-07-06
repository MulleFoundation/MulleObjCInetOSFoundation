/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSLocale.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


@interface NSLocale ( PosixFuture)

+ (NSString *) systemLocalePath;
- (id) _localeInfoForKey:(id) key;

@end


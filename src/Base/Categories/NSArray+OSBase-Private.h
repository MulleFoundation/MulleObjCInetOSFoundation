/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSArray+Posix_Private.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
@interface NSArray( Posix_Private)

+ (instancetype) _newWithArgc:(int) argc
                         argv:(char **) argv;

@end

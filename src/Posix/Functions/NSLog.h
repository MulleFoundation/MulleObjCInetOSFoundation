/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSLog.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import <MulleObjCFoundation/MulleObjCFoundation.h>

// some
void   NSLog( NSString *format, ...);
void   NSLogv( NSString *format, va_list args);

// mulle addition, NSLogv is a clang builtin...NSLogv
void   NSLogArguments( NSString *format, mulle_vararg_list args);

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSBundle+Darwin.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <dlfcn.h>


@implementation NSBundle( FreeBSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}

@end

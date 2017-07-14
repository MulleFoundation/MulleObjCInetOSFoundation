//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#include "mulle_posix_tm.h"
#import "NSLocale+PosixPrivate.h"

// std-c and dependencies
#include <time.h>
#include <locale.h>


@implementation NSDateFormatter (Linux)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}



- (size_t) _printTM:(struct tm *) tm
             buffer:(char *) buf
             length:(size_t) len
      cStringFormat:(char *) c_format
             locale:(NSLocale *) locale
{
   locale_t   old_locale;
   
   old_locale = uselocale( [locale xlocale]);
   {
      len = strftime( buf, len, c_format, &tm);
   }
   uselocale( old_locale);
   
   return( len);
}

@end

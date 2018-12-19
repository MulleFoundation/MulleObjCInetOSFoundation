//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import-private.h"

// other files in this library
#include "mulle_bsd_tm.h"

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/private/NSDate+OSBase-Private.h>
#import <MulleObjCPosixFoundation/private/NSLocale+Posix-Private.h>
#include <MulleObjCPosixFoundation/private/mulle_posix_tm-private.h>

// std-c and dependencies
#include <time.h>
#include <xlocale.h>


@implementation NSDateFormatter( BSD)

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
   locale_t    xlocale;

   xlocale  = [locale xlocale];
   if( xlocale)
      len = strftime_l( buf, len, c_format, tm, xlocale);
   else
      len = strftime( buf, len, c_format, tm);
   return( len);
}

@end

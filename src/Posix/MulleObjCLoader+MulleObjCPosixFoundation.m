//
//  MulleObjCLoader+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly

#import <MulleObjC/MulleObjC.h>


@implementation MulleObjCLoader( MulleObjCPosixFoundation)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCOSBaseFoundation) },

      { @selector( _NSPosixDateFormatter), 0 },
      { @selector( NSCondition), 0 },
      { @selector( NSBundle), @selector( Posix) },
      { @selector( NSCalendarDate), @selector( Posix) },
      { @selector( NSData), @selector( Posix) },
      { @selector( NSDirectoryEnumerator), @selector( Posix) },
      { @selector( NSFileManager), @selector( Posix) },
      { @selector( NSLocale), @selector( Posix) },
      { @selector( NSPipe), @selector( Posix) },
      { @selector( NSProcessInfo), @selector( Posix) },
      { @selector( NSRunLoop), @selector( Posix) },
      { @selector( NSTimeZone), @selector( Posix) },
      { @selector( NSTask), @selector( Posix) },
      { 0, 0 }
   };

   return( dependencies);
}

@end

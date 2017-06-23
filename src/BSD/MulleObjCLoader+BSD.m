//
//  MulleObjCLoader+BSD.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#import "MulleObjCPosixFoundation.h"

// other files in this library

// std-c and dependencies



@implementation MulleObjCLoader( BSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( OSBase) },

      { @selector( _NSGMTTimeZone), @selector( BSD) },
      { @selector( NSCalendarDate), @selector( BSD) },
      { @selector( NSDateFormatter), @selector( BSD) },
      { @selector( NSLocale), @selector( BSD) },
      { @selector( NSProcessInfo), @selector( BSD) },
      { @selector( NSTask), @selector( BSD) },
      { @selector( NSTimeZone), @selector( BSD) },
      { 0, 0 }
   };

   return( dependencies);
}

@end

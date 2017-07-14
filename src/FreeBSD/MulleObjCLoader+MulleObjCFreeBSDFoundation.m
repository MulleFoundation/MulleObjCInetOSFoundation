//
//  MulleObjCLoader+MulleObjCFreeBSDFoundation.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.07.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjC/MulleObjC.h>


@implementation MulleObjCLoader( MulleObjCFreeBSDFoundation)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      
      { @selector( NSBundle), @selector( FreeBSD) },
      { @selector( NSFileManager), @selector( FreeBSD) },
      { @selector( NSProcessInfo), @selector( FreeBSD) },
      { @selector( NSString), @selector( FreeBSD) },
      { @selector( NSTask), @selector( FreeBSD) },
      { 0, 0 }
   };
   
   return( dependencies);
}

@end

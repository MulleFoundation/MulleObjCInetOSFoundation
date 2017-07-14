//
//  MulleObjCLoader+Darwin.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.07.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjC/MulleObjC.h>


@implementation MulleObjCLoader( MulleObjCDarwinFoundation)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      
      { @selector( NSBundle), @selector( Darwin) },
      { @selector( NSFileManager), @selector( Darwin) },
      { @selector( NSProcessInfo), @selector( Darwin) },
      { @selector( NSString), @selector( Darwin) },
      { @selector( NSTask), @selector( Darwin) },
      { @selector( _NSPathUtilityVectorTable_Loader), @selector( Darwin) },
      { 0, 0 }
   };
   
   return( dependencies);
}

@end

//
//  MulleObjCLoader+MulleObjCLinuxFoundation.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 14.07.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjC/MulleObjC.h>


@implementation MulleObjCLoader( MulleObjCLinuxFoundation)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      
      { @selector( _NSGMTTimeZone), @selector( Linux) },
      { @selector( NSBundle), @selector( Linux) },
      { @selector( NSCalendarDate), @selector( Linux) },
      { @selector( NSDateFormatter), @selector( Linux) },
      { @selector( NSFileManager), @selector( Linux) },
      { @selector( NSProcessInfo), @selector( Linux) },
      { @selector( NSString), @selector( Linux) },
      { @selector( NSTask), @selector( Linux) },
      { @selector( NSTimeZone), @selector( Linux) },
      { @selector( _NSPathUtilityVectorTable_Loader), @selector( Linux) },
      { 0, 0 }
   };
   
   return( dependencies);
}

@end

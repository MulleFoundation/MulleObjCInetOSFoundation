//
//  MulleObjCLoader+OSFoundation.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 11.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCLoader+MulleObjCOSFoundation.h"


@implementation MulleObjCLoader( MulleObjCOSFoundation)


+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {

#include "dependencies.inc"

      { MULLE_OBJC_NO_CLASSID, MULLE_OBJC_NO_CATEGORYID }
   };

   return( dependencies);
}

@end

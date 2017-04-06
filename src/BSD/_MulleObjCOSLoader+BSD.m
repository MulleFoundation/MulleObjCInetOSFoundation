//
//  _MulleObjCOSLoader+BSD.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#import "MulleObjCPosixFoundation.h"

// other files in this library
#import "_MulleObjCOSLoader.h"

// std-c and dependencies



@implementation _MulleObjCOSLoader (BSD)

+ (SEL *) categoryDependencies
{
   static SEL   dependencies[] =
   {
      @selector( Posix),
      0
   };
   
   return( dependencies);
}

@end

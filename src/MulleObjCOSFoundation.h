//
//  MulleObjCPosixFoundation.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import <MulleObjCFoundation/MulleObjCFoundation.h>

#define MULLE_OBJC_OS_FOUNDATION_VERSION   MULLE_OBJC_FOUNDATION_VERSION


// BSD, OS X, Linux
#if defined( __unix__) || defined( __APPLE__)
# import <MulleObjCPosixFoundation/MulleObjCPosixFoundation.h>
#endif

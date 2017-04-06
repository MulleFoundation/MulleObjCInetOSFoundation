//
//  MulleObjCPosixFoundation.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "MulleObjCOSFoundationParents.h"

#define MULLE_OBJC_OS_FOUNDATION_VERSION   MULLE_OBJC_FOUNDATION_VERSION


// BSD, OS X, Linux

// want to have alloca available from now on

#ifdef __APPLE__
# import "MulleObjCPosixFoundation.h"
# include <alloca.h>
#else
# ifdef __linux__
#  import "MulleObjCPosixFoundation.h"
#  include <alloca.h>
# else
#  ifdef __unix__
#   import "MulleObjCPosixFoundation.h"
#   include <stdlib.h> // has alloca
#  endif
# endif
#endif

//
//  MulleObjCPosixFoundation.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define MULLE_OBJC_OS_FOUNDATION_VERSION   ((0 << 20) | (14 << 8) | 1)


#import "import.h"


// BSD, OS X, Linux

// want to have alloca available from now on

#ifdef __APPLE__
# include <alloca.h>
#else
# ifdef __linux__
#  include <alloca.h>
# else
#  ifdef __unix__
#   include <stdlib.h> // has alloca
#  endif
# endif
#endif

#if MULLE_OBJC_STANDARD_FOUNDATION_VERSION < ((0 << 20) | (14 << 8) | 0)
# error "MulleObjCStandardFoundation is too old"
#endif

#if MULLE_OBJC_INET_FOUNDATION_VERSION < ((0 << 20) | (14 << 8) | 0)
# error "MulleObjCInetFoundation is too old"
#endif

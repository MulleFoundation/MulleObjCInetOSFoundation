//
//  _MulleObjCFoundation.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 06.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCOSFoundationParents.h"

#define MULLE_OBJC_OS_FOUNDATION_VERSION   MULLE_OBJC_FOUNDATION_VERSION

// used this article: http://nadeausoftware.com/articles/2012/01/c_c_tip_how_use_compiler_predefined_macros_detect_operating_system
//

// BSD, OS X, Linux
#if defined( __unix__) || (defined(__APPLE__) && defined(__MACH__))
//# include <sys/param.h>  // get BSD
# import "MulleObjCPosixFoundation.h" // assume Posix if unix
#endif

// things simplify, becaus we don't even have these headers (yet)

//#ifdef BSD
//# import "MulleObjCBSDFoundation.h"
//#endif

//#ifdef __FreeBSD__
//# import "MulleObjCFreeBSDFoundation.h"
//#endif

//#ifdef __linux__
//# import "MulleObjCLinuxFoundation.h"
//#endif

//#if (defined(__APPLE__) && defined(__MACH__)
//# import "MulleObjCDarwinFoundation.h"
//#endif

/*
 *   This file will be regenerated by `mulle-sde reflect` and any edits will be
 *   lost. Suppress generation of this file with:
 *      mulle-sde environment --global \
 *         set MULLE_SOURCETREE_TO_C_IMPORT_FILE DISABLE
 *
 *   To not generate any header files:
 *      mulle-sde environment --global \
 *         set MULLE_SOURCETREE_TO_C_RUN DISABLE
 */

#ifndef _MulleObjCInetOSFoundation_import_h__
#define _MulleObjCInetOSFoundation_import_h__

// How to tweak the following MulleObjCInetFoundation #import
//    remove:             `mulle-sourcetree mark MulleObjCInetFoundation no-header`
//    rename:             `mulle-sde dependency|library set MulleObjCInetFoundation include whatever.h`
//    toggle #import:     `mulle-sourcetree mark MulleObjCInetFoundation [no-]import`
//    toggle localheader: `mulle-sourcetree mark MulleObjCInetFoundation [no-]localheader`
//    toggle public:      `mulle-sourcetree mark MulleObjCInetFoundation [no-]public`
//    toggle optional:    `mulle-sourcetree mark MulleObjCInetFoundation [no-]require`
//    remove for os:      `mulle-sourcetree mark MulleObjCInetFoundation no-os-<osname>`
# if defined( __has_include) && __has_include("MulleObjCInetFoundation.h")
#   import "MulleObjCInetFoundation.h"   // MulleObjCInetFoundation
# else
#   import <MulleObjCInetFoundation/MulleObjCInetFoundation.h>   // MulleObjCInetFoundation
# endif

// How to tweak the following MulleObjCOSFoundation #import
//    remove:             `mulle-sourcetree mark MulleObjCOSFoundation no-header`
//    rename:             `mulle-sde dependency|library set MulleObjCOSFoundation include whatever.h`
//    toggle #import:     `mulle-sourcetree mark MulleObjCOSFoundation [no-]import`
//    toggle localheader: `mulle-sourcetree mark MulleObjCOSFoundation [no-]localheader`
//    toggle public:      `mulle-sourcetree mark MulleObjCOSFoundation [no-]public`
//    toggle optional:    `mulle-sourcetree mark MulleObjCOSFoundation [no-]require`
//    remove for os:      `mulle-sourcetree mark MulleObjCOSFoundation no-os-<osname>`
# if defined( __has_include) && __has_include("MulleObjCOSFoundation.h")
#   import "MulleObjCOSFoundation.h"   // MulleObjCOSFoundation
# else
#   import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>   // MulleObjCOSFoundation
# endif

#ifdef __has_include
# if __has_include( "_MulleObjCInetOSFoundation-include.h")
#  include "_MulleObjCInetOSFoundation-include.h"
# endif
#endif


#endif

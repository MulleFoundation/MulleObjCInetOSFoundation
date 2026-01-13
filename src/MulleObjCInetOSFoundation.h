#ifndef mulle_objc_inet_os_foundation_h__
#define mulle_objc_inet_os_foundation_h__

#import "import.h"

#include <stdint.h>

/*
 *  (c) 2020 nat ORGANIZATION
 *
 *  version:  major, minor, patch
 */
#define MULLE_OBJC_INET_OS_FOUNDATION_VERSION  ((0UL << 20) | (20 << 8) | 7)


static inline unsigned int   MulleObjCInetOSFoundation_get_version_major( void)
{
   return( MULLE_OBJC_INET_OS_FOUNDATION_VERSION >> 20);
}


static inline unsigned int   MulleObjCInetOSFoundation_get_version_minor( void)
{
   return( (MULLE_OBJC_INET_OS_FOUNDATION_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   MulleObjCInetOSFoundation_get_version_patch( void)
{
   return( MULLE_OBJC_INET_OS_FOUNDATION_VERSION & 0xFF);
}


MULLE_OBJC_INET_OS_FOUNDATION_GLOBAL
uint32_t   MulleObjCInetOSFoundation_get_version( void);


/*
   Add your library headers here for exposure to library
   consumers.
*/
#import "NSData+NSURL.h"
#import "NSHost+OS.h"
#import "NSURL+Filesystem.h"


#ifdef __has_include
# if __has_include( "_MulleObjCExpatFoundation-versioncheck.h")
#  include "_MulleObjCExpatFoundation-versioncheck.h"
# endif
#endif


#endif

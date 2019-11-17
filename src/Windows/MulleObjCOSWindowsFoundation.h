#ifndef windows_h__
#define windows_h__

#import "import.h"

#include <stdint.h>

/*
 *  (c) 2019 nat ORGANIZATION
 *
 *  version:  major, minor, patch
 */
#define WINDOWS_VERSION  ((0 << 20) | (7 << 8) | 56)


static inline unsigned int   Windows_get_version_major( void)
{
   return( WINDOWS_VERSION >> 20);
}


static inline unsigned int   Windows_get_version_minor( void)
{
   return( (WINDOWS_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   Windows_get_version_patch( void)
{
   return( WINDOWS_VERSION & 0xFF);
}


extern uint32_t   Windows_get_version( void);

/*
   Add other library headers here like so, for exposure to library
   consumers.

   # include "foo.h"
*/
#endif

//
//  MulleStandaloneObjCPosixFoundation.c
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 03.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#include "_MulleObjCOSFoundation.h"

// other files in this library

// other libraries of MulleObjCFoundation

// std-c and other dependencies
#import <MulleObjCFoundation/MulleObjCFoundationSetup.h>


#pragma mark -
#pragma mark versioning

static void   versionassert( struct _mulle_objc_runtime *runtime,
                            void *friend,
                            struct mulle_objc_loadversion *version)
{
   if( (version->foundation & ~0xFF) != (MULLE_OBJC_OS_FOUNDATION_VERSION & ~0xFF))
      _mulle_objc_runtime_raise_inconsistency_exception( runtime, "mulle_objc_runtime %p: foundation version set to %x but runtime foundation is %x",
                                                        runtime,
                                                        version->foundation,
                                                        MULLE_OBJC_OS_FOUNDATION_VERSION);
}


__attribute__((const))  // always returns same value (in same thread)
struct _mulle_objc_runtime  *__get_or_create_objc_runtime( void)
{
   struct _mulle_objc_runtime  *runtime;
   
   runtime = __mulle_objc_get_runtime();
   if( runtime->version)
      return( runtime);
   
   {
      struct _ns_foundation_setupconfig   setup;
      
      MulleObjCFoundationGetDefaultSetupConfig( &setup);
      setup.config.runtime.versionassert = versionassert;
      return( ns_objc_create_runtime( &setup.config));
   }
}


//
// see: https://stackoverflow.com/questions/35998488/where-is-the-eprintf-symbol-defined-in-os-x-10-11/36010972#36010972
//
__attribute__((visibility("hidden")))
void __eprintf( const char* format, const char* file,
               unsigned line, const char *expr)
{
   fprintf( stderr, format, file, line, expr);
   abort();
}

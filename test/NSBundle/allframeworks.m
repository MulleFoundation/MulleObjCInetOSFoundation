//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#ifdef __MULLE_OBJC__
# import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif

//#import "MulleStandaloneObjCFoundation.h"

#include <stdio.h>


int   main( int argc, const char * argv[])
{
   NSArray   *bundles;
   NSBundle  *bundle;

   // not much we can check here
   bundles = [NSBundle allFrameworks];
#ifdef __APPLE__
   if( ! [bundles count])
   {
      printf( "fail\n");
      return( -1);
   }
#endif

   fprintf( stderr, "Informational output only (not checked):\n");
   for( bundle in bundles)
   {
      fprintf( stderr, "bundlePath     : %s\n", [[bundle bundlePath] UTF8String]);
      fprintf( stderr, "executablePath : %s\n", [[bundle executablePath] UTF8String]);
      fprintf( stderr, "resourcePath   : %s\n", [[bundle resourcePath] UTF8String]);
      fprintf( stderr, "isLoaded       : %s\n", [bundle isLoaded] ? "YES" : "NO");
   }

   return( 0);
}

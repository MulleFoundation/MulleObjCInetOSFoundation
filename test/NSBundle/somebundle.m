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
   NSBundle   *bundle;
   NSString   *bundle_exe_path;
   NSString   *bundle_path;
   NSString   *pwd;

   pwd         = [[NSFileManager defaultManager] currentDirectoryPath];
   bundle_path = [pwd stringByAppendingPathComponent:@"EmptyBundle.bundle"];
   bundle      = [[[NSBundle alloc] initWithPath:bundle_path] autorelease];
   if( ! bundle)
   {
      printf( "fail\n");
      return( -1);
   }

   bundle_path     = [bundle bundlePath];
   bundle_exe_path = [bundle executablePath];

   printf( "path: \"%s\"\n", [[bundle_path lastPathComponent] UTF8String]);
   printf( "exe : \"%s\"\n", [[bundle_exe_path lastPathComponent] UTF8String]);
   return( 0);
}

//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"

#include <stdio.h>


int   main( int argc, const char * argv[])
{
   NSString        *argv_exe;
   NSString        *bundle_exe;
   NSBundle        *bundle;

   bundle = [NSBundle mainBundle];
   if( ! bundle)
   {
      printf( "fail\n");
      return( -1);
   }

   bundle_exe = [bundle executablePath];
   argv_exe   = [NSString stringWithCString:argv[ 0]];
   if( ! [argv_exe isEqualToString:bundle_exe])
   {
      printf( "failed: %s <> %s\n",
               [bundle_exe UTF8String],
               [argv_exe UTF8String]);
      return( -1);
   }
   return( 0);
}

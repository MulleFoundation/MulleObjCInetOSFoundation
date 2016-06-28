//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleStandaloneObjCOSFoundation/MulleStandaloneObjCOSFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"

#include <stdio.h>


int   main( int argc, const char * argv[])
{
   NSString        *cString;
   NSString        *s;

   s = [[NSProcessInfo processInfo] _executablePath];
   if( ! s)
   {
      printf( "fail\n");
      return( -1);
   }

   cString = [NSString stringWithCString:argv[ 0]];
   if( ! [s isEqualToString:cString])
      printf( "failed\n");

   return( 0);
}

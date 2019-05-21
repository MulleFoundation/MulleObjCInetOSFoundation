//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"
#include <stdlib.h>



static void  test( char *s, char *expect)
{
   NSString   *result;
   NSString   *path;

   path   = [NSString stringWithCString:s];
   result = [path stringByStandardizingPath];
   if( strcmp( [result cString], expect))
      printf( "failed with \"%s\" (Expected: \"%s\")\n", 
		result ? [result cString] : "<NULL>",
		expect);
}


int   main( int argc, const char * argv[])
{
   char   *home;

   test( "/", "/");
   home = getenv( "HOME");
   test( "~", home ? home : "~");

   return( 0);
}

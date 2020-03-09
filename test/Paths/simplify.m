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



static void  test( NSString *s, NSString *expect)
{
   NSString   *result;

   result = [s mulleStringBySimplifyingPath];
   if( ! [result isEqualToString:expect])
      printf( "failed with \"%s\" (Expected: \"%s\")\n",
		          result ? [result cString] : "<NULL>",
		          [expect cString]);
}


int   main( int argc, const char * argv[])
{
   test( @"/", @"/");
   test( @".", @".");
   test( @"..", @"..");
   test( @"a", @"a");

   test( @"//", @"/");
   test( @"./", @".");
   test( @"../", @"..");
   test( @"a/", @"a/");

//      test(@"//", @"x");
   test( @"/.", @"/");
   test( @"/..", @"/");
   test( @"/a", @"/a");

   test( @"///", @"/");
   test( @"/./", @"/");
   test( @"/../", @"/");
   test( @"/a/", @"/a");

   test( @"/../..", @"/");
   test( @"/../../", @"/");
   test( @"../../", @"../..");

   test( @"/a/..", @"/");
   test( @"/../a/", @"/a");
   test( @"/../a/..", @"/");

   return( 0);
}

//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleStandaloneObjCPosixFoundation/MulleStandaloneObjCPosixFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"


#include <stdio.h>



int   main( int argc, const char * argv[])
{
   NSDictionary    *environment;
   NSEnumerator    *rover;
   NSString        *cString;
   NSString        *key;
   int             i;

   environment = [[NSProcessInfo processInfo] environment];
   if( ! [environment count])
   {
      printf( "fail\n");
      return( -1);
   }

   rover = [environment keyEnumerator];
   while( key = [rover nextObject])
   {
      cString = [NSString stringWithCString:getenv( [key cString])];
      if( ! [[environment objectForKey:key] isEqualToString:cString])
      {
          printf( "%d failed\n", i);
      }
   }

   return( 0);
}

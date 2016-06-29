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
   NSArray    *arguments;
   NSString   *cString;
   NSString   *s;
   int         i;

   arguments = [[NSProcessInfo processInfo] arguments];
   for( i = 0; i < argc; i++)
   {
      cString = [NSString stringWithCString:argv[ i]];
      s       = [arguments objectAtIndex:i];

      if( ! [s isEqualToString:cString])
      {
          printf( "%d failed (%s <> %s)\n", i, [s UTF8String], argv[ i]);
      }
   }

   return( 0);
}

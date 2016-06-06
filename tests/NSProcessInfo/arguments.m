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
   NSArray    *arguments;
   NSString   *cString;
   int         i;

   arguments = [[NSProcessInfo processInfo] arguments];
   for( i = 0; i < argc; i++)
   {
      cString = [NSString stringWithCString:argv[ i]];
      if( ! [[arguments objectAtIndex:0] isEqualToString:cString])
      {
          printf( "%d failed\n", i);
      }
   }

   return( 0);
}

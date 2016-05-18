//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleStandaloneObjCPosixFoundation/MulleStandaloneObjCPosixFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"



static void  test( char *s, char *expect)
{
   NSString   *ext;
   NSString   *path;

   path = [NSString stringWithCString:s];
   ext  = [path pathExtension];
   printf( "%s\n", strcmp( [ext cString], expect) ? "failed" : "passed");
}


int   main( int argc, const char * argv[])
{
   test( "/tmp/scratch.tiff", "tiff");
   test( ".scratch.tiff", "tiff");
   test( "/tmp/scratch", "");
   test( "/tmp/", "");
   test( "/tmp/scratch..tiff", "tiff");
   test( "/tmp/scratch.", "");

   return( 0);
}

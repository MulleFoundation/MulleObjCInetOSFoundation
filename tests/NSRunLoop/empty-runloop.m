//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"


int   main( int argc, const char * argv[])
{
   NSRunLoop  *runLoop;
   NSDate     *date;

   mulle_objc_check_runtimewaitqueues();

   runLoop = [NSRunLoop currentRunLoop];
   date    = [runLoop limitDateForMode:NSDefaultRunLoopMode];
   NSLog( @"%@", date);

   return( 0);
}

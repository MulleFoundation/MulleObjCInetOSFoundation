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


int   main( int argc, const char * argv[])
{
   NSRunLoop         *runLoop;
   NSDate            *date;
   NSTimeInterval    now;
   NSTimeInterval    interval;

#ifdef __MULLE_OBJC__
   if( mulle_objc_check_universe() != mulle_objc_universe_is_ok)
      return( 1);
#endif

   runLoop  = [NSRunLoop currentRunLoop];
   date     = [runLoop limitDateForMode:@"NoMode"];
   if( date)
      printf( "Failed\n");

   return( 0);
}

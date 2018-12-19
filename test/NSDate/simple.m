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
# pragma message( "Apple Foundation")
#endif


static void   print_fail_if( int state)
{
   if( state)
      printf( "FAIL\n");
}


int   main( int argc, const char * argv[])
{
   NSDate            *date;
   NSTimeInterval    interval;
   NSTimeInterval    interval2;
   NSTimeInterval    distantPast;
   NSTimeInterval    distantFuture;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif
   date     = [NSDate date];
   interval = [date timeIntervalSinceReferenceDate];

   distantPast   = [[NSDate distantPast] timeIntervalSinceReferenceDate];
   distantFuture = [[NSDate distantFuture] timeIntervalSinceReferenceDate];

   print_fail_if( interval == 0);
   print_fail_if( interval > distantFuture);
   print_fail_if( interval < distantPast);

   // assume this doesn't sleep more than 5 seconds
   sleep( 2);

   date      = [NSDate date];
   interval2 = [date timeIntervalSinceReferenceDate];
   print_fail_if( interval >= interval2);
   print_fail_if( interval + 5 < interval2);

   return( 0);
}

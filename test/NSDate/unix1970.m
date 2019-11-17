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


static void   check( int state)
{
   printf( state ? "OK\n" : "FAIL\n");
}


int   main( int argc, const char * argv[])
{
   NSDate            *date;
   NSTimeInterval    interval;
   NSTimeInterval    interval2;
   time_t            value;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif
   // time() returns seconds since 1970-01-01 00:00:00 +0000 (UTC).
   value     = time( NULL);
   date      = [NSDate date];

   // timeIntervalSinceReferenceDate returns seconds since 2001-01-01
   interval2 = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;

   printf( "+\n (%.1f - %ld)\n", interval2, value);
   check( interval2 >= value);
   check( interval2 < value + 10);

   interval = [date timeIntervalSince1970];
   printf( "-\n (%.1f - %ld)\n", interval, value);
   check( interval >= value);
   check( interval < value + 10);


   return( 0);
}

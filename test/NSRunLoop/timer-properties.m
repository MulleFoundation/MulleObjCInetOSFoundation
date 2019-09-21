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
   NSDate            *date;
   NSObject          *target;
   id                argument;
   NSTimeInterval    interval;
   NSDate            *newDate;
   NSTimeInterval    now;
   NSTimer           *timer;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif
   target   = [[NSObject new] autorelease];
   argument = [NSArray arrayWithObject:@1848];

   now   = [NSDate timeIntervalSinceReferenceDate];
   timer = [NSTimer timerWithTimeInterval:0.1
                                   target:target
                                 selector:@selector( self)
                                 userInfo:argument
                                  repeats:NO];

   if( ! timer)
   {
      fprintf( stderr, "failed timer\n");
      return( 1);
   }

   if( ! [[timer userInfo] isEqual:argument])
   {
      fprintf( stderr, "failed userInfo\n");
      return( 1);
   }

   date     = [timer fireDate];
   interval = [date timeIntervalSinceReferenceDate];
   if( interval < now + 0.1)
   {
      fprintf( stderr, "failed fireDate 1 \n");
      return( 1);
   }

   now = [NSDate timeIntervalSinceReferenceDate];
   if( interval > now + 0.1)
   {
      fprintf( stderr, "failed fireDate 2 \n");
      return( 1);
   }


   newDate  = [NSDate dateWithTimeIntervalSinceReferenceDate:interval+1.0];
   [timer setFireDate:newDate];

   if( ! [[timer fireDate] isEqual:newDate])
   {
      fprintf( stderr, "failed fireDate 2\n");
      return( 1);
   }
   return( 0);
}

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
@interface Foo : NSObject
@end


@implementation Foo

- (void) a:(NSTimer *) timer
{
   printf( "%s %d\n", __PRETTY_FUNCTION__, [[timer userInfo] intValue]);
}

@end



int   main( int argc, const char * argv[])
{
   NSRunLoop         *runLoop;
   NSDate            *date;
   NSTimeInterval    now;
   NSTimer           *timer;
   NSTimeInterval    interval;
   Foo               *foo;
   id                argument;
   int               i;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif
   @autoreleasepool
   {
      foo      = [[Foo new] autorelease];
      argument = [NSNumber numberWithInt:1848];
      runLoop  = [NSRunLoop currentRunLoop];

      timer = [NSTimer scheduledTimerWithTimeInterval:0.1000
                                               target:foo
                                             selector:@selector( a:)
                                             userInfo:argument
                                              repeats:NO];

      printf( "1. \n");
      now = [NSDate timeIntervalSinceReferenceDate];
      [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceReferenceDate:now]];

      // now should be later than
      if( [timer mulleFireTimeInterval] > now + 0.1000)
         printf( "Hein ???\n");

      printf( "2. \n");
      [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceReferenceDate:now + 0.1000]];

      printf( "3. \n");
      [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceReferenceDate:now + 0.1000]];

      printf( "4. \n");
   }

   return( 0);
}

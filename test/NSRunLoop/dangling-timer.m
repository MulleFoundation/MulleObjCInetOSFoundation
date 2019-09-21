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
// cc -o dangling-timer.apple.exe -g -O0 dangling-timer.m -framework Foundation
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

// the timer will be reclaimed though
- (void) dealloc
{
   printf( "%s\n", __PRETTY_FUNCTION__);
   [super dealloc];
}


+ (void) runThread:(id) unused
{
   Foo   *foo;
   id    argument;

   @autoreleasepool
   {
      foo      = [[Foo new] autorelease];
      argument = [NSNumber numberWithInt:1848];
      [NSTimer scheduledTimerWithTimeInterval:0.5
                                       target:foo
                                     selector:@selector( a:)
                                     userInfo:argument
                                      repeats:NO];
      // will not fire here
      //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
   }
}

@end



int   main( int argc, const char * argv[])
{
   NSRunLoop   *runLoop;
   NSLock      *lock;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   [NSThread detachNewThreadSelector:@selector( runThread:)
                            toTarget:[Foo class]
                          withObject:nil];
   sleep( 1);

   // timer is scheduled but will not fire, will it be reclaimed though ?

   return( 0);
}

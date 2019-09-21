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

- (void) dealloc
{
   printf( "%s\n", __PRETTY_FUNCTION__);
   [super dealloc];
}


- (void) whatever:(id) unused
{
   printf( "%s\n", __PRETTY_FUNCTION__);
}

@end



int   main( int argc, const char * argv[])
{
   NSRunLoop   *runLoop;
   NSLock      *lock;
   Foo         *foo;
   id          argument;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   foo      = [[Foo new] autorelease];
   argument = @[ @1848];

   printf( "Setup\n");
   [[NSRunLoop currentRunLoop] performSelector:@selector( whatever:)
                                        target:foo
                                      argument:argument
                                         order:1848
                                         modes:@[ @"foo"]];
   printf( "Exit\n");

   // timer is scheduled but will not fire, will it be reclaimed though ?

   return( 0);
}

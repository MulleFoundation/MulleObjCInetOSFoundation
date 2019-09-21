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

- (void) a:(NSNumber *) nr
{
   printf( "%s %d\n", __PRETTY_FUNCTION__, [nr intValue]);
}


- (void) b:(NSNumber *) nr
{
   printf( "%s %d\n", __PRETTY_FUNCTION__, [nr intValue]);
}


- (void) c:(NSNumber *) nr
{
   printf( "%s %d\n", __PRETTY_FUNCTION__, [nr intValue]);
}


@end



int   main( int argc, const char * argv[])
{
   Foo               *foo;
   id                argument;
   int               i;
   NSDate            *date;
   NSRunLoop         *runLoop;
   NSTimeInterval    interval;
   NSTimeInterval    now;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif
   foo      = [[Foo new] autorelease];
   argument = [NSNumber numberWithInt:1848];
   runLoop  = [NSRunLoop currentRunLoop];

   [runLoop performSelector:@selector( a:)
                     target:foo
                   argument:argument
                      order:1000
                      modes:@[ @"bar"]];

   [runLoop performSelector:@selector( a:)
                     target:foo
                   argument:argument
                      order:100000
                      modes:@[ @"foo"]];

   [runLoop performSelector:@selector( b:)
                     target:foo
                   argument:argument
                      order:10000
                      modes:@[ @"foo"]];

   [runLoop performSelector:@selector( c:)
                     target:foo
                   argument:argument
                      order:1000
                      modes:@[ @"foo"]];

   // test lots of messages, just to make sure realloc works
   for( i = 0; i < 32; i++)
   {
      [runLoop performSelector:@selector( c:)
                        target:foo
                      argument:[NSNumber numberWithInt:i]
                         order:i
                         modes:@[ @"foo"]];
   }

   //
   // these will eventually produce duplicate orders
   // the earlier messages should be called first if the order is same
   // which is for those on the range 16-48
   //
   for( i = 32; i < 64; i++)
   {
      [runLoop performSelector:@selector( c:)
                        target:foo
                      argument:[NSNumber numberWithInt:i]
                         order:64+16-i
                         modes:@[ @"foo"]];
   }

   [runLoop cancelPerformSelector:@selector( b:)
                           target:foo
                         argument:argument];

   [runLoop _sendMessagesOfRunLoopMode:[runLoop mulleRunLoopModeForMode:@"foo"]];

   return( 0);
}

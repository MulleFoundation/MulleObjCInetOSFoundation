//
//  NSRunLoop.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 20.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "NSRunLoop.h"

#import "NSFileHandle.h"

#include <errno.h>
#include <string.h>


NSString   *NSDefaultRunLoopMode = @"NSDefaultRunLoopMode";


@implementation NSRunLoop

- (id) init
{
   self = [super init];
   if( self)
   {
      assert( NSIntMapKeyCallBacks.notakey);  // zero must be allowed
      _modeTable = NSCreateMapTable( NSObjectMapKeyCallBacks,
                                     NSOwnedPointerMapValueCallBacks,
                                     32);
      _fileHandleTable = NSCreateMapTable( NSIntMapKeyCallBacks,
                                           NSObjectMapValueCallBacks,
                                           32);
      _readyHandles = [NSMutableArray new];
   }
   return( self);
}


- (void) dealloc
{
   if( _modeTable)
      NSFreeMapTable( _modeTable);
   if( _fileHandleTable)
      NSFreeMapTable( _fileHandleTable);
   [_readyHandles release];
   
   [super dealloc];
}


+ (NSRunLoop *) currentRunLoop
{
   NSThread              *thread;
   NSMutableDictionary   *threadDictionary;
   NSRunLoop             *runLoop;
   
   thread           = [NSThread currentThread];
   threadDictionary = [thread threadDictionary];
   
   NSCParameterAssert( threadDictionary);
   
   runLoop          = [threadDictionary objectForKey:@"NSRunLoop"];
   if( runLoop)
      return( runLoop);
   
   runLoop = [NSRunLoop new];
   
   NSParameterAssert( runLoop);
   
   [threadDictionary setObject:runLoop
                        forKey:@"NSRunLoop"];
   [runLoop release];
   
   return( runLoop);
}


- (void) acceptInputForMode:(NSString *) mode
                 beforeDate:(NSDate *) date
{
   if( _currentMode)
      [NSException raise:NSInternalInconsistencyException
                  format:@"NSRunLoop is not re-entrant"];
   
   _currentMode = mode;
   [self _acceptInputForMode:mode
                  beforeDate:date];
   _currentMode = nil;
}


- (NSDate *) limitDateForMode:(NSString *) mode
{
   [self acceptInputForMode:mode
                  beforeDate:nil];
   
   // should check for next timer here later
   return( nil);
}


- (NSString *) currentMode
{
   return( _currentMode);
}


- (void) runUntilDate:(NSDate *) date
{
   NSTimeInterval   until;
   
   NSParameterAssert( [date isKindOfClass:[NSDate class]]);

   until = [date timeIntervalSinceReferenceDate];
   while( [NSDate timeIntervalSinceReferenceDate] < until)
   {
      if( ! [self runMode:NSDefaultRunLoopMode
               beforeDate:date])
         break;
   }
}


- (void) run
{
   [self runUntilDate:[NSDate distantFuture]];
}

@end

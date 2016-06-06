//
//  NSTask+BSD.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 06.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import "NSTask+PosixPrivate.h"

// std-c and dependencies
#include <signal.h>


@implementation NSTask( BSD)

- (void) waitUntilExit
{
   switch( _status)
   {
   default :
      MulleObjCThrowInternalInconsistencyException( @"task not started");
      break;
      
   case _NSTaskIsPresumablyRunning :
      NSParameterAssert( _pid);
      waitpid( _pid, &_terminationStatus, WNOHANG);
      
   case _NSTaskHasTerminated :
      break;
   }
}


- (void) _signal:(int) a_signal
{
   switch( _status)
   {
      default :
         MulleObjCThrowInternalInconsistencyException( @"task not started");
         break;
         
      case _NSTaskIsPresumablyRunning :
         NSParameterAssert( _pid);
         kill( _pid, a_signal);
         
      case _NSTaskHasTerminated :
         break;
   }
}


- (void) terminate
{
   [self _signal:SIGTERM];
}


- (void) interrupt
{
   [self _signal:SIGINT];
}


- (BOOL) suspend
{
   [self _signal:SIGSTOP];
   return( YES);
}


- (BOOL) resume
{
   [self _signal:SIGCONT];
   return( YES);
}


- (NSTaskTerminationReason) terminationReason
{
   switch( _status)
   {
      default :
         MulleObjCThrowInternalInconsistencyException( @"task not terminated yet");
         
      case _NSTaskHasTerminated :
         break;
   }
   
   if( WIFEXITED( _terminationStatus))
      return( NSTaskTerminationReasonExit);
   return( NSTaskTerminationReasonUncaughtSignal);
}


@end

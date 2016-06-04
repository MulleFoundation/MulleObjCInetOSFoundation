/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask+Darwin.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__ 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import "NSTask+Private.h"

#include <signal.h>


@interface NSTask( _Darwin)
@end


@implementation NSTask( _Darwin)

+ (char **) _environment
{
   return( *_NSGetEnviron());
}


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

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSTask.h"

// other files in this library
#import "NSFileManager.h"
#import "NSFileHandle.h"
#import "NSPipe.h"
#import "NSProcessInfo.h"
#import "NSString+CString.h"
#import "NSString+OSBase.h"
#import "NSTask+Private.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <unistd.h>


@implementation NSTask

+ (NSTask *) launchedTaskWithLaunchPath:(NSString *) path
                              arguments:(NSArray *) arguments
{
   id   task;

   task = [[self new] autorelease];
   [task setLaunchPath:path];
   [task setArguments:arguments];
   [task launch];

   return( task);
}


//
// MEMO: missing methods need to be implemented OS specific
//       see -> Darwin
//
- (int) processIdentifier
{
   return( _pid);
}


- (int) terminationStatus
{
   return( _terminationStatus);
}


- (void) setArguments:(NSArray *) arguments
{
   [_arguments autorelease];
   _arguments = [arguments copy];
}


- (void) setCurrentDirectoryPath:(NSString *) path
{
   [_directoryPath autorelease];
   _directoryPath = [path copy];
}


- (void) setEnvironment:(NSDictionary *) dictionary
{
   [_environment autorelease];
   _environment = [dictionary copy];
}


- (void) setLaunchPath:(NSString *) path
{
   [_launchPath autorelease];
   _launchPath = [path copy];
}


- (void) setStandardError:(id) file
{
   [_standardError autorelease];
   _standardError = [file retain];
}


- (void) setStandardInput:(id) file
{
   [_standardInput autorelease];
   _standardInput = [file retain];
}


- (void) setStandardOutput:(id) file
{
   [_standardOutput autorelease];
   _standardOutput = [file retain];
}


- (id) standardError
{
   if( ! _standardError)
      return( [NSFileHandle fileHandleWithStandardError]);
   return( _standardError);
}


- (id) standardInput
{
   if( ! _standardInput)
      return( [NSFileHandle fileHandleWithStandardInput]);
   return( _standardInput);
}


- (id) standardOutput
{
   if( ! _standardOutput)
      return( [NSFileHandle fileHandleWithStandardOutput]);
   return( _standardOutput);
}


- (NSArray *) arguments
{
   return( _arguments);
}


- (NSString *) launchPath
{
   return( _launchPath);
}


- (NSString *) currentDirectoryPath
{
   if( ! _directoryPath)
      return( [[NSFileManager defaultManager] currentDirectoryPath]);
   return( _directoryPath);
}


- (NSDictionary *) environment
{
   // or use NSUserDefaults ??
   if( ! _environment)
      return( [[NSProcessInfo processInfo] environment]);
   return( _environment);
}

@end


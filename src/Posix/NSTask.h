/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSTask.h is a part of MulleFoundation
 *
 *  Copyright (C)  2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import <MulleObjCFoundation/MulleObjCFoundation.h>


enum 
{
   NSTaskTerminationReasonExit           = 1,
   NSTaskTerminationReasonUncaughtSignal = 2
};

typedef NSInteger   NSTaskTerminationReason;


@class NSArray;
@class NSDictionary;
@class NSString;
@class NSFileHandle;


@interface NSTask : NSObject
{
   NSString      *_launchPath;
   NSArray       *_arguments;
   NSString      *_directoryPath;
   NSDictionary  *_environment;
   
   id            _standardError;
   id            _standardInput;
   id            _standardOutput;
   
   int           _pid;
   int           _status;
   int           _terminationStatus;
}


+ (NSTask *) launchedTaskWithLaunchPath:(NSString *) path 
                              arguments:(NSArray *) arguments;
- (BOOL) isRunning;

- (void) interrupt;
- (void) launch;
- (BOOL) resume;
- (BOOL) suspend;
- (void) terminate;
- (void) waitUntilExit;

- (void) setArguments:(NSArray *) arguments;
- (void) setCurrentDirectoryPath:(NSString *) path;
- (void) setEnvironment:(NSDictionary *) environmentDictionary;
- (void) setLaunchPath:(NSString *) path;
- (void) setStandardError:(id) file;
- (void) setStandardInput:(id) file;
- (void) setStandardOutput:(id) file;

- (int) processIdentifier;
- (int) terminationStatus;
- (NSTaskTerminationReason) terminationReason;

- (id) standardError;
- (id) standardInput;
- (id) standardOutput;

- (NSArray *) arguments;
- (NSString *) launchPath;
- (NSString *) currentDirectoryPath;
- (NSDictionary *) environment;

@end


/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import "NSTask.h"

// other files in this library
#import "NSFileManager.h"
#import "NSProcessInfo.h"
#import "NSTask+Private.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


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


static void   do_the_dup( int fd, id handle)
{
   int  other_fd;
   
   if( ! handle)
      return;
     
   //
   // Example: child stdin(0), pipe is [0/1] [read/write]
   // so parent "writes" into pipe[ 1] for child( 0) via pipe[ 0]
   // Ergo: child gets pipe[ 0] dupped
   // 
   // Other example: child stdout(1), pipe is [0/1] [read/write]
   // so we "read" from pipe[ 0], where child( 1) writes into via pipe[ 1]
   // Ergo: child gets pipe[ 1] dupped
   //
   
   other_fd = (! fd) ? [handle _fileDescriptorForReading] : [handle _fileDescriptorForWriting]; 
   if( other_fd != fd)
   {
      close( fd);
      dup( other_fd);
      
      // don't close other_fd, its "handle"'s job
   }
}

 
- (void) launch
{
   pid_t   pid;
   
   if( ! (pid = vfork()))
   {
      void   **argv;
      void   **envp;
      char   *path;
      int    argc;
      int    i;
      
      _status = _NSTaskIsPresumablyRunning;
      
      path     = [_launchPath fileSystemRepresentation];

      argc = [_arguments count];
      argv = alloca( (argc + 2) * sizeof( void *));
      [_arguments getObjects:(id *) &argv[ 1]];
      for( i = 1; i <= argc; i++) 
         argv[ i] = [(id) argv[ i] cString];
      argv[ i] = 0;
      argv[ 0] = path;  // [[_launchPath lastPathComponent] cString];

      envp     = [NSTask _environment];
      
      //
      // in the end, we might leak a few filedescriptors
      // until child exits 
      //
      do_the_dup( 0, _standardInput);
      do_the_dup( 1, _standardOutput);
      do_the_dup( 2, _standardError);
      
      execve( path, (char **) argv, envp);

      // oughta be back in "parent" here
      _status = _NSTaskHasFailed;
      // error
      MulleObjCThrowInvalidArgumentException( self, "could not launch");
   }
   
   _pid = pid;
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


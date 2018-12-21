//
//  NSTask+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 06.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _XOPEN_SOURCE 700

#import "import-private.h"

#import <MulleObjCOSBaseFoundation/private/NSTask-Private.h>

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <sys/types.h>
#include <unistd.h>


@implementation NSTask (Posix)


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

   // don't use vfork anymore (might do it on BSDs though)
   if( ! (pid = fork()))
   {
      char         **envp;
      char         *path;
      NSUInteger   argc;
      NSUInteger   i;

      _status = _NSTaskIsPresumablyRunning;

      path    = [_launchPath fileSystemRepresentation];

      argc = [_arguments count];

      {
         void  *argv[ argc + 2];

         [_arguments getObjects:(id *) &argv[ 1]];
         for( i = 1; i <= argc; i++)
            argv[ i] = [(id) argv[ i] cString];
         argv[ i] = 0;
         argv[ 0] = path;  // [[_launchPath lastPathComponent] cString];

         envp = [NSTask _environment];

         //
         // in the end, we might leak a few filedescriptors
         // until child exits
         //
         do_the_dup( 0, _standardInput);
         do_the_dup( 1, _standardOutput);
         do_the_dup( 2, _standardError);
         execve( path, (char **) argv, envp);
      }

      // oughta be back in "parent" here
      _status = _NSTaskHasFailed;
      // error
      MulleObjCThrowInvalidArgumentException( @"%@ could not launch", self);
   }

   _pid = pid;
}

@end

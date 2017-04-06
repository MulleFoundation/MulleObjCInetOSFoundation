/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask+System.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSTask+System.h"

// other files in this library
#import "NSPipe.h"
#import "NSFileHandle.h"
#import "NSString+CString.h"
#import "NSString+OSBase.h"

// std-c and dependencies



@implementation NSTask( System)

+ (NSString *) _system:(NSArray *) argv
      workingDirectory:(NSString *) dir
{
   NSString      *path;
   NSTask        *task;
   NSPipe        *pipe;
   NSArray       *arguments;
   NSFileHandle  *file;
   NSString      *s;
   NSData        *data;
   NSInteger     argc;

   argc = [argv count];
   NSParameterAssert( argc);

   task = [[NSTask new] autorelease];
   pipe = [NSPipe pipe];

   path = [argv objectAtIndex:0];
   NSParameterAssert( [path isAbsolutePath]);
   [task setLaunchPath:path];

   arguments = [argv subarrayWithRange:NSMakeRange( 1, argc - 1)];
   [task setArguments:arguments];
   [task setStandardInput:[NSPipe pipe]];
   [task setStandardOutput:pipe];
   if( [dir length])
      [task setCurrentDirectoryPath:dir];
   [task launch];
   [task waitUntilExit];
   if( [task terminationStatus] != 0)
      return( nil);

   file = [pipe fileHandleForReading];
   data = [file readDataToEndOfFile];
   s    = [NSString stringWithCString:[data bytes]
                               length:[data length]];

   s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

   return( s);
}


+ (NSString *) _systemWithString:(NSString *) s
                workingDirectory:(NSString *) dir
{
   NSArray   *argv;

   argv = [s componentsSeparatedByString:@" "];
   return( [self _system:argv
        workingDirectory:dir]);
}

@end

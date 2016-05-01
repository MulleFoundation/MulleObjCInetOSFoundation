/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSProcessInfo.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSProcessInfo.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSProcessInfo

+ (NSProcessInfo *) processInfo
{
   static id  processInfo;
   
   if( ! processInfo)
      processInfo = [self new];
   return( processInfo);
}

- (NSArray *) arguments
{
   return( _arguments);
}


- (NSDictionary *) environment
{
   return( _environment);
}


- (NSString *) hostName
{
   return( @"localhost");
}


- (NSUInteger) operatingSystem
{
   return( NSDarwinOperatingSystem);
}


- (NSString *) operatingSystemName
{
   return( @"Darwin");
}


- (int) processIdentifier
{
   return( getpid());
}


- (NSString *) processName
{
   return( @"process");
}


- (void) setProcessName:(NSString *) name
{
}

@end


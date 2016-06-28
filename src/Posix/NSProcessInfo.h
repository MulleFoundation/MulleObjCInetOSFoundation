/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSProcessInfo.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
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
   NSWindowsNTOperatingSystem = 1,
   NSWindows95OperatingSystem,
   NSSolarisOperatingSystem,
   NSHPUXOperatingSystem,
   NSDarwinOperatingSystem,
   NSSunOSOperatingSystem,
   NSOSF1OperatingSystem,
   NSLinuxOperatingSystem,
   NSBSDOperatingSystem
};


@interface NSProcessInfo : NSObject < MulleObjCSingleton>
{
   NSArray       *_arguments;
   NSDictionary  *_environment;
   NSString      *_executablePath;
}


+ (NSProcessInfo *) processInfo;

- (NSString *) globallyUniqueString;
- (int) processIdentifier;


@end


@interface NSProcessInfo ( OSSpecific)

- (NSString *) hostName;

- (NSUInteger) operatingSystem;
- (NSString *) operatingSystemName;
- (NSString *) operatingSystemVersionString;

- (NSArray *) arguments;
- (NSDictionary *) environment;
- (NSString *) _executablePath;

- (NSString *) processName;
- (void) setProcessName:(NSString *) name;

@end

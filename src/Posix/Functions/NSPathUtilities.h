/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSPathUtilities.h is a part of MulleFoundation
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
   NSUserDomainMask    = 1,
   NSLocalDomainMask   = 2,
   NSNetworkDomainMask = 4,
   NSSystemDomainMask  = 8,
   NSAllDomainsMask    = 0xFFFFFFFF
};

typedef NSUInteger   NSSearchPathDomainMask;


enum {
   NSApplicationDirectory = 1,
   NSAdminApplicationDirectory,
   NSDeveloperDirectory,
   NSDeveloperApplicationDirectory,
   NSLibraryDirectory,
   NSUserDirectory,
   NSApplicationSupportDirectory,
   NSDocumentationDirectory,
   NSDocumentDirectory,
   NSDesktopDirectory,
   NSAllApplicationsDirectory,
   NSAllLibrariesDirectory
};
typedef NSUInteger NSSearchPathDirectory;


@class NSString;
@class NSArray;



extern NSString  *NSFullUserName( void);
extern NSString  *NSHomeDirectory( void);
extern NSString  *NSHomeDirectoryForUser( NSString *userName);
extern NSString  *NSOpenStepRootDirectory( void);
extern NSArray   *NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory directory,      
                                                       NSSearchPathDomainMask domainMask, 
                                                       BOOL expandTilde);
extern NSString  *NSTemporaryDirectory( void);
extern NSString  *NSUserName( void);


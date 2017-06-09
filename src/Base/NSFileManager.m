/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager.m is a part of MulleFoundation
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

#import "NSFileManager.h"

// other files in this library
#import "NSDirectoryEnumerator.h"
#import "NSData+OSBase.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


NSString   *NSFileAppendOnly            = @"NSFileAppendOnly";
NSString   *NSFileBusy                  = @"NSFileBusy";
NSString   *NSFileCreationDate          = @"NSFileCreationDate";
NSString   *NSFileDeviceIdentifier      = @"NSFileDeviceIdentifier";
NSString   *NSFileExtensionHidden       = @"NSFileExtensionHidden";
NSString   *NSFileGroupOwnerAccountID   = @"NSFileGroupOwnerAccountID";
NSString   *NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";
NSString   *NSFileHFSCreatorCode        = @"NSFileHFSCreatorCode";
NSString   *NSFileHFSTypeCode           = @"NSFileHFSTypeCode";
NSString   *NSFileImmutable             = @"NSFileImmutable";
NSString   *NSFileModificationDate      = @"NSFileModificationDate";
NSString   *NSFileOwnerAccountID        = @"NSFileOwnerAccountID";
NSString   *NSFileOwnerAccountName      = @"NSFileOwnerAccountName";
NSString   *NSFilePosixPermissions      = @"NSFilePosixPermissions";
NSString   *NSFileReferenceCount        = @"NSFileReferenceCount";
NSString   *NSFileSize                  = @"NSFileSize";
NSString   *NSFileSystemFileNumber      = @"NSFileSystemFileNumber";
NSString   *NSFileSystemNumber          = @"NSFileSystemNumber";
NSString   *NSFileType                  = @"NSFileType";

NSString   *NSFileTypeBlockSpecial     = @"NSFileTypeBlockSpecial";
NSString   *NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
NSString   *NSFileTypeDirectory        = @"NSFileTypeDirectory";
NSString   *NSFileTypePipe             = @"NSFileTypePipe";
NSString   *NSFileTypeRegular          = @"NSFileTypeRegular";
NSString   *NSFileTypeSocket           = @"NSFileTypeSocket";
NSString   *NSFileTypeSymbolicLink     = @"NSFileTypeSymbolicLink";
NSString   *NSFileTypeUnknown          = @"NSFileTypeUnknown";


@interface NSDirectoryEnumerator ( NSFileManager)

- (instancetype) initWithFileManager:(NSFileManager *) manager
                  rootPath:(NSString *) root
             inheritedPath:(NSString *) inherited;
- (instancetype) initWithFileManager:(NSFileManager *) manager
                 directory:(NSString *) path;

@end


@implementation NSFileManager

//
// need to make this thread safe ?
// spec is dubious, it says you should do alloc/init
// for thread safety.  (but why ?)
// There are no instance variables here ??
// (probably for the delegate, that we don't support)
//
+ (NSFileManager *) defaultManager
{
   return( [NSFileManager sharedInstance]);
}


- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path
{
   return( [[[NSDirectoryEnumerator alloc] initWithFileManager:self
                                                     directory:path] autorelease]);
}


// useless fluff routines
- (BOOL) createFileAtPath:(NSString *) path
                 contents:(NSData *) contents
               attributes:(NSDictionary *) attributes
{
   BOOL      flag;
   NSError   *error;

   if( ! [contents writeToFile:path
                      atomically:NO])
      return( NO);

   flag = [self setAttributes:attributes
                 ofItemAtPath:path
                        error:&error];
   return( flag);
}


- (NSData *) contentsAtPath:(NSString *) path
{
   return( [NSData dataWithContentsOfFile:path]);
}


- (BOOL) contentsEqualAtPath:(NSString *) path1
                     andPath:(NSString *) path2
{
   NSData  *data1;
   NSData  *data2;

   data1 = [NSData dataWithContentsOfFile:path1];
   data2 = [NSData dataWithContentsOfFile:path2];
   return( [data1 isEqualToData:data2]);
}

@end


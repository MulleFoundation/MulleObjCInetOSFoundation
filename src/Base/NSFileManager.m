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
#import "NSData+OSBase.h"
#import "NSDirectoryEnumerator.h"
#import "NSString+OSBase.h"
#import "NSPageAllocation.h"

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


- (void) dealloc
{
   [super dealloc];
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


- (BOOL) _removeDirectoryItemAtPath:(NSString *) path
{
   NSArray   *contents;
   NSString  *name;
   NSString  *itemPath;

   contents = [self directoryContentsAtPath:path];
   for( name in contents)
   {
      itemPath = [path stringByAppendingPathComponent:name];
      if( ! [self removeItemAtPath:itemPath])
      {
         if( [_delegate respondsToSelector:@selector(fileManager:shouldProceedAfterError:removingItemAtPath:)])
            if( ! [_delegate fileManager:self
                shouldProceedAfterError:[NSError mulleCurrentError]
                     removingItemAtPath:path])
               return( NO);
      }
   }

   return( [self _removeEmptyDirectoryItemAtPath:path]);
}


- (BOOL) removeItemAtPath:(NSString *) path
{
   BOOL   flag;
   BOOL   isDirectory;

   if( ! [self fileExistsAtPath:path
                    isDirectory:&isDirectory])
      return( NO);

   if( [_delegate respondsToSelector:@selector(fileManager:shouldRemoveItemAtPath:)])
      if( ! [_delegate fileManager:self
          shouldRemoveItemAtPath:path])
         return( NO);

   if( isDirectory)
      flag = [self _removeDirectoryItemAtPath:path];
   else
      flag = [self _removeFileItemAtPath:path];

   return( flag);
}


- (BOOL) removeItemAtPath:(NSString *) path
                    error:(NSError **) error
{
   if( ! [self removeItemAtPath:path] && error)
   {
      *error = [NSError mulleCurrentError];
      return( NO);
   }

   return( YES);
}


- (BOOL) removeFileAtPath:(NSString *) path
                  handler:(id) handler
{
    if( [handler respondsToSelector:@selector( fileManager:willProcessPath:)])
        [handler fileManager:self
             willProcessPath:path];

    return( [self removeItemAtPath:path
                             error:NULL]);
}


- (BOOL) createDirectoryAtPath:(NSString *) path
                    attributes:(NSDictionary *) attributes
{
   return( [self createDirectoryAtPath:path
           withIntermediateDirectories:NO
                            attributes:attributes
                                 error:NULL]);
}


- (BOOL) createSymbolicLinkAtPath:(NSString *) path
                      pathContent:(NSString *) otherpath
{
   return( [self createSymbolicLinkAtPath:path
                      withDestinationPath:otherpath
                                    error:NULL]);
}

@end


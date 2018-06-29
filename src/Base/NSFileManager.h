/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "dependencies.h"


@class NSDirectoryEnumerator;


extern NSString   *NSFileType;
extern NSString   *NSFileSize;
extern NSString   *NSFileModificationDate;
extern NSString   *NSFileReferenceCount;
extern NSString   *NSFileDeviceIdentifier;
extern NSString   *NSFileOwnerAccountName;
extern NSString   *NSFileGroupOwnerAccountName;
extern NSString   *NSFilePosixPermissions;
extern NSString   *NSFileSystemNumber;
extern NSString   *NSFileSystemFileNumber;
extern NSString   *NSFileExtensionHidden;
extern NSString   *NSFileHFSCreatorCode;
extern NSString   *NSFileHFSTypeCode;
extern NSString   *NSFileImmutable;
extern NSString   *NSFileAppendOnly;
extern NSString   *NSFileCreationDate;
extern NSString   *NSFileOwnerAccountID;
extern NSString   *NSFileGroupOwnerAccountID;
extern NSString   *NSFileBusy;

extern NSString   *NSFileTypeDirectory;
extern NSString   *NSFileTypePipe;
extern NSString   *NSFileTypeRegular;
extern NSString   *NSFileTypeSymbolicLink;
extern NSString   *NSFileTypeSocket;
extern NSString   *NSFileTypeCharacterSpecial;
extern NSString   *NSFileTypeBlockSpecial;
extern NSString   *NSFileTypeUnknown;


@interface NSFileManager : NSObject < MulleObjCSingleton>
{
}

+ (NSFileManager *) defaultManager;

- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path;
- (BOOL) createDirectoryAtPath:(NSString *) path
   withIntermediateDirectories:(BOOL) createIntermediates
                    attributes:(NSDictionary *) attributes
                         error:(NSError **) error;

// useless fluff routines
- (BOOL) createFileAtPath:(NSString *) path
                 contents:(NSData *) contents
               attributes:(NSDictionary *)attributes;


- (NSData *) contentsAtPath:(NSString *) path;
- (BOOL) contentsEqualAtPath:(NSString *) path1
                     andPath:(NSString *) path2;

@end

@interface NSFileManager (Future)

- (BOOL) changeCurrentDirectoryPath:(NSString *) path;
- (NSString *) currentDirectoryPath;
- (BOOL) fileExistsAtPath:(NSString *) path;
- (BOOL) fileExistsAtPath:(NSString *) path
              isDirectory:(BOOL *) isDirectory;
- (BOOL) isDeletableFileAtPath:(NSString *) path;
- (BOOL) isExecutableFileAtPath:(NSString *) path;
- (BOOL) isReadableFileAtPath:(NSString *) path;
- (BOOL) isWritableFileAtPath:(NSString *) path;

- (NSDictionary *) fileSystemAttributesAtPath:(NSString *) path;

- (NSString *) pathContentOfSymbolicLinkAtPath:(NSString *) path;

- (NSArray *) directoryContentsAtPath:(NSString *) path;


- (NSDictionary *) fileSystemAttributesAtPath:(NSString *) path;
- (NSArray *) directoryContentsAtPath:(NSString *) path;
- (NSString *) pathContentOfSymbolicLinkAtPath:(NSString *) path;

- (char *) fileSystemRepresentationWithPath:(NSString *) path;
- (NSString *) stringWithFileSystemRepresentation:(char *) s
                                           length:(NSUInteger) len;

- (BOOL) setAttributes:(NSDictionary *) attributes
          ofItemAtPath:(NSString *) path
                 error:(NSError **) error;

- (int) _createDirectoryAtPath:(NSString *) path
                    attributes:(NSDictionary *) attributes;

@end


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
#import "import.h"


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


@class NSFileManager;

@protocol NSFileManagerHandler

@optional
- (void)  fileManager:(NSFileManager *) fileManager
      willProcessPath:(NSString *) path;

@end


@interface NSFileManager : NSObject < MulleObjCSingleton>

@property( assign) id   delegate;

+ (NSFileManager *) defaultManager;

- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path;

// useless fluff routines
- (BOOL) createFileAtPath:(NSString *) path
                 contents:(NSData *) contents
               attributes:(NSDictionary *)attributes;


- (NSData *) contentsAtPath:(NSString *) path;
- (BOOL) contentsEqualAtPath:(NSString *) path1
                     andPath:(NSString *) path2;

- (BOOL) removeFileAtPath:(NSString *) path
                  handler:(id) handler;


// Apple deprecates, Mulle supports
- (BOOL) createDirectoryAtPath:(NSString *)path
                    attributes:(NSDictionary *)attributes;

- (BOOL) createSymbolicLinkAtPath:(NSString *) path
                      pathContent:(NSString *) otherpath;
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

- (BOOL) createSymbolicLinkAtPath:(NSString *) path
              withDestinationPath:(NSString *) otherpath
                            error:(NSError **) error;

- (BOOL) createDirectoryAtPath:(NSString *) path
   withIntermediateDirectories:(BOOL) createIntermediates
                    attributes:(NSDictionary *) attributes
                         error:(NSError **) error;

- (NSDictionary *) fileSystemAttributesAtPath:(NSString *) path;

- (NSString *) pathContentOfSymbolicLinkAtPath:(NSString *) path;

- (NSArray *) directoryContentsAtPath:(NSString *) path;


- (NSDictionary *) fileSystemAttributesAtPath:(NSString *) path;
- (NSDictionary *) fileAttributesAtPath:(NSString *) path
                           traverseLink:(BOOL) flag;

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

- (BOOL) _removeFileItemAtPath:(NSString *) path;
- (BOOL) _removeEmptyDirectoryItemAtPath:(NSString *) path;
- (BOOL) removeItemAtPath:(NSString *) path
                    error:(NSError **) error;

@end



@protocol NSFileManagerDelegate

@optional

- (BOOL) fileManager:(NSFileManager *)fileManager
shouldRemoveItemAtPath:(NSString *)path;

- (BOOL) fileManager:(NSFileManager *)fileManager
shouldProceedAfterError:(NSError *)error
  removingItemAtPath:(NSString *)path;

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldMoveItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath;

- (BOOL) fileManager:(NSFileManager *)fileManager
 shouldMoveItemAtPath:(NSString *)srcPath
               toPath:(NSString *)dstPath;

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldCopyItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath;

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldProceedAfterError:(NSError *)error
  copyingItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath;

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldLinkItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath;

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldProceedAfterError:(NSError *)error
  linkingItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath;

@end

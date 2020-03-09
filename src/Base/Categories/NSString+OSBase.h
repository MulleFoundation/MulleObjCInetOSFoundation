/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+PosixPathHandling.h is a part of MulleFoundation
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


@interface NSString( OSBase)

+ (instancetype) pathWithComponents:(NSArray *) components;

- (BOOL) isAbsolutePath;
- (NSString *) lastPathComponent;
- (NSString *) pathExtension;
- (NSString *) stringByAppendingPathComponent:(NSString *) component;
- (NSString *) stringByAppendingPathExtension:(NSString *) extension;
- (NSString *) stringByDeletingLastPathComponent;
- (NSString *) stringByDeletingPathExtension;
- (NSString *) stringByExpandingTildeInPath;
- (NSString *) stringByResolvingSymlinksInPath;
- (NSString *) stringByStandardizingPath;

- (NSArray *) pathComponents;
- (NSString *) initWithPathComponents:(NSArray *) components;

- (char *) fileSystemRepresentation;
- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max;

+ (instancetype) stringWithContentsOfFile:(NSString *) path;

#pragma mark -
#pragma mark mulle additions

- (NSString *) mulleStringBySimplifyingPath;  // just removes /./ and /../

- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag;

- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
            encoding:(NSStringEncoding) encoding
               error:(NSError **) error;
@end


@interface NSString( OSBaseFuture)

- (instancetype) initWithContentsOfFile:(NSString *) path;

@end

extern NSString  *NSFilePathComponentSeparator;
extern NSString  *NSFilePathExtensionSeparator;


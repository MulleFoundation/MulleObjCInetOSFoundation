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
#import "dependencies.h"


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

- (NSString *) _stringBySimplifyingPath;  // just removes /./ and /../

@end


@interface NSString( OSBaseFuture)

- (instancetype) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag;

@end

extern NSString  *NSFilePathComponentSeparator;
extern NSString  *NSFilePathExtensionSeparator;


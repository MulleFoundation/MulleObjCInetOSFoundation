//
//  NSURL+PosixPathHandling.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "NSURL+OSBase.h"

// other files in this library
#import "NSString+OSBase.h"

// std-c and dependencies


NSString   *NSURLFileScheme = @"file";


@implementation NSURL( OSBase)

- (char *) fileSystemRepresentation
{
   return( [[self path] fileSystemRepresentation]);
}


- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max
{
   return( [[self path] getFileSystemRepresentation:buf
                                          maxLength:max]);
}



//
// We don't convenience, if path is a directory and append '/'.
// It's not really foolproof either:
//  touch foo/a ;  initFile... ; rm foo/a ; mkdir foo/a
//
- (instancetype) initFileURLWithPath:(NSString *) path
{
   return( [self initWithScheme:NSURLFileScheme
                           host:nil
                           path:path]);
}


+ (instancetype) fileURLWithPath:(NSString *) path
{
   return( [[[self alloc] initFileURLWithPath:path] autorelease]);
}


- (instancetype) initFileURLWithPath:(NSString *) path
                         isDirectory:(BOOL) isDirectory
{
   return( [self initWithScheme:NSURLFileScheme
                           host:nil
                           path:path]);
}


+ (instancetype) fileURLWithPath:(NSString *) path
                     isDirectory:(BOOL) isDirectory
{
   return( [[[self alloc] initFileURLWithPath:path
                                  isDirectory:isDirectory] autorelease]);
}

+ (NSURL *) fileURLWithPathComponents:(NSArray *)components
{
   return( [self fileURLWithPath:[NSString pathWithComponents:components]]);
}


@end

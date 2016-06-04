//
//  NSURL+PosixPathHandling.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSURL+PosixPathHandling.h"

// other files in this library
#import "NSString+PosixPathHandling.h"

// std-c and dependencies



@implementation NSURL (PosixPathHandling)

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

@end

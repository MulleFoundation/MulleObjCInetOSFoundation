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

@end

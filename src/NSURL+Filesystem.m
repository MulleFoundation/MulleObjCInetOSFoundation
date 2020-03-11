//
//  NSURL+Filesystem.m
//  MulleObjCInetOSFoundation
//
//  Created by Nat! on 18.05.16.
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "NSURL+Filesystem.h"

// other files in this library

// std-c and dependencies
#import "import-private.h"


NSString   *NSURLFileScheme = @"file";


@implementation NSURL( Filesystem)

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

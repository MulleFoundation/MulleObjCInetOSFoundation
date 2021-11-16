//  NSData+NSURL.h
//  MulleObjCInetOSFoundation
//
//  Created by Nat! on 10.02.20.
//
//  Copyright (c) 2011 Nat! - Mulle kybernetiK
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
#import "NSData+NSURL.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#import "import-private.h"


@implementation NSData( NSURL)


#pragma mark - URL


+ (instancetype) dataWithContentsOfURL:(NSURL *) url
{
   if( [url isFileURL])
   {
      return( [self dataWithContentsOfFile:[url path]]);
   }
   return( nil);
}


- (instancetype) initWithContentsOfURL:(NSURL *) url
{
   if( [url isFileURL])
      return( [self initWithContentsOfFile:[url path]]);
   return( nil);
}


- (BOOL) writeToURL:(NSURL *) url
         atomically:(BOOL) flag
{
   if( [url isFileURL])
   {
      return( [self writeToFile:[url path]
                     atomically:flag]);
   }
   return( NO);
}


+ (instancetype) dataWithContentsOfURL:(NSURL *) url
                               options:(NSUInteger) options
                                 error:(NSError **) error
{
   if( error)
      *error = nil;
   return( [self dataWithContentsOfURL:url]);
}

@end

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSData+Posix.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSData+OSBase.h"

// other files in this library
#import "NSString+OSBase.h"
#import "NSLog.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSData( OSBase)

+ (instancetype) dataWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


+ (instancetype) dataWithContentsOfMappedFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfMappedFile:path] autorelease]);
}


#pragma mark -
#pragma mark URL


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

//
//  NSDictionary+Posix.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSDictionary+OSBase.h"

// other files in this library
#import "NSData+OSBase.h"

// std-c and dependencies

@interface NSObject( Private)

- (BOOL) __isNSDictionary;
- (BOOL) __isNSMutableDictionary;

@end


@implementation NSDictionary( OSBase)

+ (instancetype) dictionaryWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   NSData                            *data;
   NSPropertyListMutabilityOptions   options;
   id                                old;

   options = NSPropertyListImmutable;
   if( [self __isNSMutableDictionary])
      options = NSPropertyListMutableContainers;

   @autoreleasepool
   {
      data = [NSData dataWithContentsOfFile:path];
      old  = self;
      self = [NSPropertyListSerialization propertyListFromData:data
                                              mutabilityOption:options
                                                        format:NULL
                                              errorDescription:NULL];
      [old release];
      [self retain];
   }

   if( ! [self __isNSDictionary])
   {
      [self release];
      return( nil);
   }
   return( self);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSString  *error;
   NSData    *data;
   BOOL      rval;

   @autoreleasepool
   {
      data = [NSPropertyListSerialization dataFromPropertyList:self
                                                        format:NSPropertyListOpenStepFormat
                                              errorDescription:&error];
      rval = [data writeToFile:path
                    atomically:flag];
   }
   return( rval);
}

@end

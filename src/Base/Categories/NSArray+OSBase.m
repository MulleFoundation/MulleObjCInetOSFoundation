//
//  NSArray+Posix.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#import "NSArray+OSBase.h"

// other files in this library
#import "NSData+OSBase.h"

// std-c and dependencies


@interface NSObject( Private)

- (BOOL) __isNSArray;
- (BOOL) __isNSMutableArray;

@end


@implementation NSArray (Posix)

+ (instancetype) arrayWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   NSData                            *data;
   id                                plist;
   NSPropertyListMutabilityOptions   options;
   NSPropertyListFormat              format;
   id                                old;

   options = NSPropertyListImmutable;
   if( [self __isNSMutableArray])
      options = NSPropertyListMutableContainers;

   data   = [NSData dataWithContentsOfFile:path];
   format = NSPropertyListOpenStepFormat;
   plist  = [NSPropertyListSerialization propertyListFromData:data
                                            mutabilityOption:options
                                                      format:&format
                                            errorDescription:NULL];
   old = self;
   // memo: do not call class methods hereafter
   if( ! [plist __isNSArray])
      self = nil;
   else
      self = [plist retain];
   [old release];
   return( self);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSString  *error;
   NSData    *data;

   data = [NSPropertyListSerialization dataFromPropertyList:self
                                                     format:NSPropertyListOpenStepFormat
                                           errorDescription:&error];
   return( [data writeToFile:path
                  atomically:flag]);
}

@end

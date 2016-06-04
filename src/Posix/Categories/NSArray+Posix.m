//
//  NSArray+Posix.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSArray+Posix.h"

// other files in this library
#import "NSData+Posix.h"

// std-c and dependencies

@interface NSObject (Private)

- (BOOL) __isNSArray;
- (BOOL) __isNSMutableArray;

@end


@implementation NSArray (Posix)

+ (id) arrayWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


- (id) initWithContentsOfFile:(NSString *) path
{
   NSData                            *data;
   id                                plist;
   NSPropertyListMutabilityOptions   options;
   
   options = NSPropertyListImmutable;
   if( [self __isNSMutableArray])
      options = NSPropertyListMutableContainers;
   
   data  = [NSData dataWithContentsOfFile:path];
   plist = [NSPropertyListSerialization propertyListFromData:data
                                            mutabilityOption:options
                                                      format:NULL
                                            errorDescription:NULL];
  [self release];

   if( ! [plist __isNSArray])
      return( nil);
   return( [plist retain]);
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

//
//  NSArchiver+Posix.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#import "NSArchiver+OSBase.h"

// other files in this library
#import "NSData+OSBase.h"

// std-c and dependencies



@implementation NSArchiver (OSBase)

+ (BOOL) archiveRootObject:(id) rootObject
                    toFile:(NSString *) path
{
   NSData   *data;

   //
   // use a flushable mulle_buffer here, if written to file
   // -archiverData will return nil then
   //
   data = [self archivedDataWithRootObject:rootObject];
   return( [data writeToFile:path
                  atomically:YES]);
}

@end

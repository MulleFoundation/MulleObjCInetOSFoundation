//
//  NSBundle+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 29.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE         

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <link.h>


@implementation NSBundle (Linux)


- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) value
                               table:(NSString *) tableName
{
   NSParameterAssert( ! key || [key isKindOfClass:[NSString class]]);
   NSParameterAssert( ! tableName || [tableName isKindOfClass:[NSString class]]);
   NSParameterAssert( ! value || [value isKindOfClass:[NSString class]]);
   
   return( key);
}


static int  collect_bundles( struct dl_phdr_info *info, size_t size, void *userinfo)
{
   NSMutableArray   *array;
   NSString         *path;
   NSBundle         *bundle;
   size_t           len;
   
   array = userinfo;
   
   // exe has no name it seems
   len  = strlen( info->dlpi_name);
   if( ! len)
      return( 0);
   
   path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:info->dlpi_name
                                                                      length:len];
   //
   // path is really the executable path, what is my bundle path ??
   // probably the same
   bundle = [[[NSBundle alloc] initWithPath:path] autorelease];
   [array addObject:bundle];
   
   return( 0);
}


+ (NSArray *) allImages
{
   NSMutableArray  *array;
   
   array = [NSMutableArray array];
   dl_iterate_phdr( collect_bundles, array);
   return( array);
}

@end

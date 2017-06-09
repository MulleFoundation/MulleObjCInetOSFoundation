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

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( Posix) },
      { 0, 0 }
   };

   return( dependencies);
}


- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) value
                               table:(NSString *) tableName
{
   NSParameterAssert( ! key || [key isKindOfClass:[NSString class]]);
   NSParameterAssert( ! tableName || [tableName isKindOfClass:[NSString class]]);
   NSParameterAssert( ! value || [value isKindOfClass:[NSString class]]);

   return( key);
}


static int  collect_filesystem_libraries( struct dl_phdr_info *info, size_t size, void *userinfo)
{
   NSMutableArray   *array;
   NSString         *path;
   NSBundle         *bundle;
   size_t           len;

   array = userinfo;

   // binary itself has no name it seems

   len = strlen( info->dlpi_name);
   if( ! len)
      return( 0);

   // no absolute path ? injected by kernel
   if( info->dlpi_name[ 0] != '/')
      return( 0);

   path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:info->dlpi_name
                                                                      length:len];
   [array addObject:path];

   return( 0);
}


+ (NSArray *) _allImagePaths
{
   NSMutableArray  *array;

   array = [NSMutableArray array];
   dl_iterate_phdr( collect_filesystem_libraries, array);
   return( array);
}

@end

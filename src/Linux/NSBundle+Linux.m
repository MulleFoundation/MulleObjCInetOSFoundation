//
//  NSBundle+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 29.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/private/NSBundle-Private.h>

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <link.h>


@implementation NSBundle (Linux)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


static int  collect_filesystem_libraries( struct dl_phdr_info *info,
                                          size_t size,
                                          void *userinfo)
{
   NSBundle                         *bundle;
   NSFileManager                    *manager;
   NSMutableData                    *data;
   size_t                           len;
   uintptr_t                        section_end;
   unsigned int                     i;
   unsigned int                     n;
   struct _MulleObjCSharedLibrary   libInfo;


   // binary itself has no name it seems

   len = strlen( info->dlpi_name);
   if( ! len)
      return( 0);
   // no absolute path ? injected by kernel
   if( info->dlpi_name[ 0] != '/')
      return( 0);

   libInfo.start = info->dlpi_addr;
   libInfo.end   = libInfo.start;
   n             = info->dlpi_phnum;
   for( i = 0; i < n; i++)
   {
      section_end = (uintptr_t) (libInfo.start +
                                 info->dlpi_phdr[i].p_vaddr +
                                 info->dlpi_phdr[i].p_memsz);
      if( section_end > libInfo.end)
         libInfo.end = section_end;
   }

   manager      = [NSFileManager defaultManager];
   libInfo.path = [manager stringWithFileSystemRepresentation:(char *) info->dlpi_name
                                                       length:len];
   data = userinfo;
   [data appendBytes:&libInfo
              length:sizeof( libInfo)];

   return( 0);
}


+ (NSData *) _allSharedLibraries
{
   NSMutableData  *data;

   data = [NSMutableData data];
   dl_iterate_phdr( collect_filesystem_libraries, data);
   return( data);
}


+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( [extension isEqualToString:@"so"]);
}

@end

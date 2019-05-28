/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSBundle+Darwin.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#define _DARWIN_C_SOURCE

// eek eeek eek, should be OSX rather than Darwin

#import "import-private.h"

#import <MulleObjCOSBaseFoundation/private/NSBundle-Private.h>

// other files in this library

// std-c and dependencies
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/swap.h>
#include <mach-o/fat.h>

#pragma clang diagnostic ignored "-Wparentheses"


@implementation NSBundle( Darwin)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
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


//   extern int   _NSGetExecutablePath( char *buf, size_t *bufsize);

//+ (NSString *) _mainExecutablePath
//{
//   NSString   *s;
//   char       *buf;
//   char       dummy;
//   uint32_t   len;
//
//   len = 0;
//   buf = &dummy;
//   _NSGetExecutablePath( buf, &len);
//
//   buf = [[NSMutableData dataWithLength:len] mutableBytes];
//   _NSGetExecutablePath( buf, &len);
//   s = [[NSFileManager sharedInstance] stringWithFileSystemRepresentation:buf
//                                                                  length:len];
//   return( s);
//}

static NSString   *executableFilename( NSBundle *self)
{
   NSString  *filename;

   filename = [[self bundlePath] lastPathComponent];
   return( [filename stringByDeletingPathExtension]);
}



static NSString   *contentsPath( NSBundle *self)
{
   NSFileManager   *manager;
   NSString        *contents;
   NSString        *path;
   BOOL            isDir;

   // now _path will have changed
   // here on OS X a bundle is
   manager   = [NSFileManager defaultManager];
   path      = [self bundlePath];
   contents  = [path stringByAppendingPathComponent:@"Contents"];

   if( [manager fileExistsAtPath:contents
                     isDirectory:&isDir] && isDir)
   {
      return( contents);
   }
   return( path);
}


//
//
- (NSString *) _resourcePath
{
   NSString   *path;
   NSString   *s;
   BOOL       flag;

   s    = contentsPath( self);
   path = [s stringByAppendingPathComponent:@"Resources"];
   if( [[NSFileManager defaultManager] fileExistsAtPath:path
                                            isDirectory:&flag] && flag)
      return( path);

   return( s);
}


- (NSString *) _executablePath
{
   NSString        *path;
   NSString        *contents;
   NSString        *exe;
   NSFileManager   *manager;

   manager = [NSFileManager defaultManager];

   exe      = executableFilename( self);
   contents = contentsPath( self);

   path = [contents stringByAppendingPathComponent:[NSBundle _OSIdentifier]];
   path = [path stringByAppendingPathComponent:exe];

   if( [manager isExecutableFileAtPath:path])
      return( path);

   path = [contents stringByAppendingPathComponent:exe];
   if( [manager isExecutableFileAtPath:path])
      return( path);
   return( nil);  // or what ??
}


// TODO: THIS IS UNTESTED AND HACKED TOGETHER!!
+ (NSData *) _allSharedLibraries
{
   char                             *s;
   NSFileManager                    *fileManager;
   NSMutableData                    *data;
   NSString                         *path;
   struct _MulleObjCSharedLibrary   libInfo;
   struct mach_header               *header;
   uint8_t                          *imageHeaderPtr;
   unsigned long                    i;
   struct segment_command_64        *segment64;
   struct segment_command           *segment;
   struct load_command              *cmd;
   int                              ncmd;
   uintptr_t                        segment_end;

   data = [NSMutableData data];

   fileManager = [NSFileManager defaultManager];
   for( i = 0; s = (char *) _dyld_get_image_name( i); i++)
   {
      if( ! strlen( s) || s[ 0] != '/')
         continue;

      header        = (struct mach_header *) _dyld_get_image_header( i);
      libInfo.start = (NSUInteger) header;
      libInfo.end   = libInfo.start;
      if( header->magic == MH_MAGIC_64)
      {
         ncmd = ((struct mach_header_64 *) header)->ncmds;
         cmd  = (struct load_command *) &((uint8_t *) header)[ sizeof( struct mach_header_64)];
      }
      else
      {
         ncmd = header->ncmds;
         cmd  = (struct load_command *) &((uint8_t *) header)[ sizeof( struct mach_header)];
      }

      for( i = 0; i < ncmd; i++)
      {
         switch( cmd->cmd)
         {
         default :
            continue;

         case LC_SEGMENT_64 :
            segment64   = (struct segment_command_64 *) cmd;
            segment_end = segment64->vmaddr + segment64->vmsize;
            break;

         case LC_SEGMENT :
            segment     = (struct segment_command *) cmd;
            segment_end = segment->vmaddr + segment->vmsize;
            break;
         }

         if( segment_end > libInfo.end)
            libInfo.end = segment_end;

         cmd = (struct load_command *)  &((uint8_t *) cmd)[ cmd->cmdsize];
      }

      libInfo.path = [fileManager stringWithFileSystemRepresentation:s
                                                             length:strlen( s)];
      [data appendBytes:&libInfo
                 length:sizeof( libInfo)];
   }

   return( data);
}


+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) executablePath
{
   NSString   *dir;
   NSString   *architecture;

   // i hate calling this too often
   NSParameterAssert( [executablePath isEqualToString:[executablePath stringByResolvingSymlinksInPath]]);

   dir          = [executablePath stringByDeletingLastPathComponent];
   architecture = [dir lastPathComponent];
   if( [architecture isEqualToString:[self _OSIdentifier]])
   {
      dir = [dir stringByDeletingLastPathComponent];
      dir = [dir stringByDeletingLastPathComponent];
   }
   return( dir);
}


static BOOL  isCurrentOS( NSString *s)
{
   return( [s isEqualToString:[NSBundle _OSIdentifier]]);
}


static BOOL  hasFrameworkExtension( NSString *s)
{
   return( [[s pathExtension] isEqualToString:@"framework"]);
}


+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( [extension isEqualToString:@"dylib"] || [extension isEqualToString:@"bundle"]);
}


// bundles can be Frameworks
// bundles can be PlugIns
// the mainBundle is either an App or a Tool,
//   both which is not treated by this method
//
+ (NSString *) _bundlePathForExecutablePath:(NSString *) executablePath
{
   NSString   *dir;
   NSString   *fallback;

   // i hate calling this too often, so assume this is done but alss check
   NSParameterAssert( [executablePath isEqualToString:[executablePath stringByResolvingSymlinksInPath]]);

   if( [[executablePath pathExtension] isEqualToString:@"dylib"])
      return( executablePath);

   dir      = [executablePath stringByDeletingLastPathComponent];
   fallback = dir;

   //
   // PlugIns.
   //
   if( isCurrentOS( [dir lastPathComponent]))         // check for "MacOS"
   {
      dir = [dir stringByDeletingLastPathComponent];  // Consume that
      dir = [dir stringByDeletingLastPathComponent];  // consume Contents
      return( dir);
   }

   // could be a Framework, then dir is probably
   // /Library/Frameworks/Foo.framework/Versions/A
   if( hasFrameworkExtension( dir))
      return( dir);

   //
   // skip over version number
   //
   dir = [dir stringByDeletingLastPathComponent];
   if( ! [[dir lastPathComponent] isEqualToString:@"Versions"])
      return( fallback);

   dir = [dir stringByDeletingLastPathComponent];
   if( hasFrameworkExtension( dir))
      return( dir);

   return( fallback);
}


#pragma mark -
#pragma mark Info.plist

- (NSDictionary *) infoDictionary
{
   abort();
   return( nil);
}


- (NSString *) bundleIdentifier
{
   abort();
}


- (Class) principalClass
{
   abort();
}

@end

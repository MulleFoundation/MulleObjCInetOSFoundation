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


@interface NSBundle( Posix)

- (NSString *) _posixResourcePath;

@end


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
static NSString   *contentsPath( NSBundle *self)
{
   NSString   *path;

   // now _path will have changed
   // here on OS X a bundle is
   path = [self bundlePath];
   path = [path stringByAppendingPathComponent:@"Contents"];
   return( path);
}

// used by Bundles/Executables
static NSString   *contentsResourcesPath( NSBundle *self)
{
   NSString   *resourcesPath;
   NSString   *path;

   // now _path will have changed
   // here on OS X a bundle is
   path = contentsPath( self);
   path = [path stringByAppendingPathComponent:@"Resources"];
   return( path);
}


// used by Frameworks
static NSString   *resourcesPath( NSBundle *self)
{
   NSString   *path;

   // now _path will have changed
   // here on OS X a bundle is
   path = [self bundlePath];
   path = [path stringByAppendingPathComponent:@"Resources"];
   return( path);
}


//
// On Darwin, we have to differentiate between true bundles, frameworks
// and "just" libraries
//
- (NSString *) _resourcePath
{
   NSFileManager    *manager;
   NSString         *path;
   BOOL             isDir;

   manager = [NSFileManager defaultManager];

   //
   // if there is no "Contents" folder, use POSIX style
   // we allow a "late" Resources order to appear though
   //
   path = contentsResourcesPath( self);
   if( [manager fileExistsAtPath:path
                     isDirectory:&isDir])
   {
      if( isDir)
         return( path);
   }

   path = resourcesPath( self);
   if( [manager fileExistsAtPath:path
                     isDirectory:&isDir])
   {
      if( isDir)
         return( path);
   }

   //
   // No Resources ? use POSIX if dylib!
   //
   // Can only do this, if we have an _exectutablePath.
   // If we are a regular bundle, this might not be determined so
   // just check ivar (see _executablePath below)
   //
   if( [[_executablePath pathExtension] isEqualToString:@"dylib"])
      return( [self _posixResourcePath]);

   // else stay in bundlePath
   return( [self bundlePath]);
}


//
// there are basically two ways a bundle comes into existence:
// we have loaded a shared library and therefore an executable path.
// this is non-negotiable. Or we got a .bundle and we are looking in
// it's plist for the proper executable path.
//
- (NSString *) _executablePath
{
   NSString        *path;
   NSString        *contents;
   NSString        *exe;
   NSFileManager   *manager;

   //
   // this can only work on Darwin
   // First figure out, if we have a valid executable already. If we do
   // we skip this.
   //
   exe = nil;
   if( ! _executablePath)
      exe = [[self infoDictionary] objectForKey:@"NSExecutable"];

   if( ! exe)
   {
      NSString  *filename;

      filename = [[self bundlePath] lastPathComponent];
      if( [[filename pathExtension] isEqualToString:@"dylib"])
      {
         // it's a dylib, so use as is
         return( _path);
      }

      // otherwise assume layout struture
      // Contents/MacOS/foobar or so
      exe = [filename stringByDeletingPathExtension];
   }

   contents = contentsPath( self);

   path = [contents stringByAppendingPathComponent:[NSBundle _OSIdentifier]];
   path = [path stringByAppendingPathComponent:exe];

   manager = [NSFileManager defaultManager];
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
   int                              ncmd;
   NSFileManager                    *fileManager;
   NSMutableData                    *data;
   NSString                         *path;
   struct _MulleObjCSharedLibrary   libInfo;
   struct load_command              *cmd;
   struct mach_header               *header;
   struct segment_command           *segment;
   struct segment_command_64        *segment64;
   uint8_t                          *imageHeaderPtr;
   uintptr_t                        segment_end;
   unsigned long                    i;
   unsigned long                    j;

   data = [NSMutableData data];

   fileManager = [NSFileManager defaultManager];
   for( i = 0; s = (char *) _dyld_get_image_name( i); i++)
   {
      assert( i < 10000); //
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

      while( --ncmd >= 0)
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

   // we can not use .. as bundlepath, because there can be multiple
   // dylibs in one diretory, and bundlePath would conflict
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


- (NSString *) bundleIdentifier
{
   id              value;
   NSDictionary   *info;

   info  = [self infoDictionary];
   value = [info objectForKey:@"CFBundleIdentifier"];
   if( value)
      return( value);
   return( [info objectForKey:@"NSBundleIdentifier"]);
}



- (BOOL) preflightAndReturnError:(NSError **) error
{
   NSString  *exePath;
   char      *c_path;

   exePath  = [self executablePath];
   c_path   = [exePath fileSystemRepresentation];
   if( ! c_path)
   {
      dlerror(); // reset so next time it's NULL indicating errno to be used
      return( NO);
   }

   if( dlopen_preflight( c_path))
      return( YES);

   //
   // NSPOSIXErrorDomain is kinda wrong, it's easier NSPOSIXErrorDomain
   // or really DLError and that has no code.
   // TODO: _loadFailureReason should probably return an NSError
   //
   if( error)
      *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                   code:errno
                               userInfo:@{ @"NSLocalizedDescriptionKey": [self _loadFailureReason] }];
   return( NO);
}


@end

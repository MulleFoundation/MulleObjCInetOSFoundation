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
#include <mach-o/dyld.h>


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



+ (NSArray *) _allImagePaths
{
   NSMutableArray  *array;
   uint32_t         i;
   char             *s;
   NSString         *path;
   NSFileManager    *fileManager;

   array = [NSMutableArray array];

   fileManager = [NSFileManager defaultManager];
   for( i = 0; s = (char *) _dyld_get_image_name( i); i++)
   {
      if( ! strlen( s) || s[ 0] != '/')
         continue;

      path = [fileManager stringWithFileSystemRepresentation:s
                                                      length:strlen( s)];

      [array addObject:path];
   }

   return( array);
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


+ (NSBundle *) bundleForClass:(Class) aClass
{
   abort();
}

@end

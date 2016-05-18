/*
 *  MulleFoundation - A tiny Foundation replacement
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

// eek eeek eek, should be OSX rather than Darwin

#import "MulleObjCPosixFoundation.h"

// other files in this library

// std-c and dependencies
#include <dlfcn.h>
#include <mach-o/dyld.h>


@implementation NSBundle( _Darwin)

+ (NSArray *) allImages
{
   NSBundle         *bundle;
   NSMutableArray   *array;
   NSString         *path;
   NSString         *s;
   char             *c_s;
   uint32_t         i, n;
   
   array = [NSMutableArray array];
   
   n = _dyld_image_count();
   for( i = 0; i < n; i++)
   {
      @autoreleasepool
      {
         c_s = (char *) _dyld_get_image_name( i);
         s   = [NSString stringWithCString:c_s];
         if( [s isEqualToString:[self _mainExecutablePath]])
            bundle = [self mainBundle];
         else
         {
            s    = [s stringByResolvingSymlinksInPath];
            path = [NSBundle _inferiorBundlePathForExecutablePath:s];
            if( path)
               bundle = [self bundleWithPath:path];
         }
#if DEBUG
         fprintf( stderr, "image: %s -> %s\n", c_s, [[bundle bundlePath] fileSystemRepresentation]);
#endif
         
         if( bundle)
            [array addObject:bundle];
      }
   }
   return( array);
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

+ (NSString *) _mainExecutablePath
{
   NSString   *s;
   char       *buf;
   char       dummy;
   uint32_t   len;

   len = 0;
   buf = &dummy;
   _NSGetExecutablePath( buf, &len);
   
   buf = [[NSMutableData dataWithLength:len] mutableBytes];
   _NSGetExecutablePath( buf, &len);
   s = [[NSFileManager sharedInstance] stringWithFileSystemRepresentation:buf
                                                                  length:len];
   return( s);
}


#pragma mark -
#pragma mark Info.plist

- (NSDictionary *) infoDictionary
{
   NSString       *path;
   NSString       *framework_plist;
   NSString       *app_plist;
   NSDictionary   *plist;
   
   if( _infoDictionary)
      return( _infoDictionary);
   
   path = [self bundlePath];
   
   framework_plist = [path stringByAppendingPathComponent:@"Resources"];
   framework_plist = [framework_plist stringByAppendingPathComponent:@"Info.plist"];
   
   // framework:  <path>/Resources/Info.plist
   plist = [NSDictionary dictionaryWithContentsOfFile:framework_plist];
   if( ! plist)
   {
      app_plist = [path stringByAppendingPathComponent:@"Contents"];
      app_plist = [framework_plist stringByAppendingPathComponent:@"Info.plist"];
   // apps: <path>/Contents/Info.plist
      plist = [NSDictionary dictionaryWithContentsOfFile:framework_plist];
      if( ! plist)
         plist = [NSDictionary dictionary];
   }

   _infoDictionary = [plist retain];
   return( _infoDictionary);
}


- (NSString *) bundleIdentifier
{
   return( [[self infoDictionary] objectForKey:@"CFBundleIdentifier"]);
}


- (Class) principalClass
{
   NSString  *className;
   
   className = [[self infoDictionary] objectForKey:@"NSPrincipalClass"];
   if( ! className)
      return( Nil);
   return( NSClassFromString( className));
}


@end

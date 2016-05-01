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
   NSAutoreleasePool   *pool;
   NSBundle            *bundle;
   NSMutableArray      *array;
   NSString            *path;
   NSString            *s;
   char                *c_s;
   uint32_t            i, n;
   
   array = [NSMutableArray array];
   
   n = _dyld_image_count();
   for( i = 0; i < n; i++)
   {
     pool =  NSPushAutoreleasePool();
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
      NSPopAutoreleasePool( pool);
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

@end

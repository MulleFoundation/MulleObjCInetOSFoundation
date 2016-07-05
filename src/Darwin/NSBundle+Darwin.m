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

#import "MulleObjCPosixFoundation.h"

// other files in this library

// std-c and dependencies
#include <dlfcn.h>
#include <mach-o/dyld.h>


@implementation NSBundle( _Darwin)


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



+ (NSArray *) allImages
{
   NSMutableArray  *array;
   uint32_t         i;
   char             *s;
   NSString         *executablePath;
   NSString         *path;
   NSBundle         *bundle;
   
   array = [NSMutableArray array];

   for( i = 0; s = (char *) _dyld_get_image_name( i); i++)
   {
      
      executablePath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:s
                                                                         length:strlen( s)];
         
      //
      // path is really the executable path, what is my bundle path
      // on OS X, we need to figure it out ...
      //
      // App:
      //    binary is in Contents/MacOSX/<binary>
      // Bundle:
      //    binary is in Contents/MacOSX/<binary>
      // Framework:
      //    binary is in Versions/A/<binary>
      // Shared Library
      //    binary is in <binary>
      
      // use some lame heursitic until I think of something better
      path = executablePath;
      if( ! [[executablePath pathExtension] isEqualToString:@"dylib"])
      {
         // get rid of exe
         path = [path stringByDeletingLastPathComponent];
         // get rid of A/MacOSX
         path = [path stringByDeletingLastPathComponent];
         // get rid of Contents/Versions
         path = [path stringByDeletingLastPathComponent];
      }
         
      bundle = [[[NSBundle alloc] _initWithPath:path
                                 executablePath:executablePath] autorelease];
      [array addObject:bundle];
   }
   
   return( array);
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

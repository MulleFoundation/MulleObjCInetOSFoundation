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

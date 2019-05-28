//
//  NSBundle+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _GNU_SOURCE

#import "import-private.h"

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/private/NSBundle-Private.h>

// std-c and dependencies
#include <dlfcn.h>


@implementation NSBundle (Posix)


+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( [extension isEqualToString:@"so"]);
}


- (NSString *) _resourcePath
{
   NSString   *s;

   s = [self executablePath];
   s = [s stringByDeletingLastPathComponent]; // remove a.out
   s = [s stringByDeletingLastPathComponent]; // remove bin
   s = [s stringByAppendingPathComponent:@"share"]; // add share

   return( s);
}


- (NSString *) _executablePath
{
   return( _path);
}


+ (NSBundle *) bundleForClass:(Class) aClass
{
   NSDictionary                     *bundleInfo;
   NSBundle                         *bundle;
   NSUInteger                       classAddress;
   struct _MulleObjCSharedLibrary   libInfo;
   NSString                         *path;
   NSString                         *bundlePath;
   Dl_info                          info;

   if( ! aClass)
      return( nil);

   classAddress = MulleObjCClassGetLoadAddress( aClass);
   assert( classAddress);

   if( dladdr( (void *) classAddress, &info))
   {
      path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:(char *) info.dli_fname
                                                                         length:strlen( info.dli_fname)];
      bundleInfo = [self mulleRegisteredBundleInfo];
      for( bundlePath in bundleInfo)
      {
         bundle = [bundleInfo objectForKey:bundlePath];
         if( [[bundle executablePath] isEqualToString:path])
            return( bundle);
      }
   }


   //
   // spec demands to create a bundle for the class now
   // Does it demand we register it ? If we don't the same
   // class will reside in different bundles over time
   // (Not caring right now)
   //
   libInfo.path  = nil;
   libInfo.start = classAddress;
   libInfo.end   = classAddress;

   path          = [NSString stringWithFormat:@"/pseudoproc/memory/%llx", classAddress];
   bundle        = [[[self alloc] _mulleInitWithPath:path
                              sharedLibraryInfo:&libInfo] autorelease];
   return( bundle);
}


- (BOOL) loadBundle
{
   NSString  *exePath;
   char      *c_path;

   exePath  = [self executablePath];
   c_path   = [exePath fileSystemRepresentation];
   if( ! c_path)
   {
      errno = EINVAL;
      return( NO);
   }

   [self willLoad];

   // check to see if alreay loaded
   // RTLD_LAZY | RTLD_GLOBAL crashed for me
   _handle = dlopen( c_path, RTLD_LAZY);
   if( ! _handle)
      return( NO);

   [self didLoad];

   return( YES);
}


- (BOOL) unloadBundle
{
   if( _handle)
   {
      if( dlclose( _handle))
         MulleObjCThrowInternalInconsistencyException( @"dlclose: %s", dlerror());
      _handle = NULL;
   }

   return( NO);
}


- (NSString *) _loadFailureReason
{
   return( [NSString stringWithCString:dlerror()]);
}

@end

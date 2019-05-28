/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSBundle.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSBundle.h"
#import "NSBundle-Private.h"

// other files in this library
#import "NSDirectoryEnumerator.h"
#import "NSFileManager.h"
#import "NSLog.h"
#import "NSProcessInfo.h"
#import "NSString+CString.h"
#import "NSString+OSBase.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <dlfcn.h>


NSString   *NSLoadedClasses             = @"NSLoadedClasses";
NSString   *NSBundleDidLoadNotification = @"NSBundleDidLoadNotification";


@implementation NSBundle

// TODO: put it in the class vars
static NSMutableDictionary  *registeredBundleInfo;


+ (void) unload
{
   [registeredBundleInfo release];
}


+ (NSUInteger) _getOwnedObjects:(id *) objects
                         length:(NSUInteger) length
{
   return( MulleObjCCopyObjects( objects, length, 1, registeredBundleInfo));
}


static NSBundle  *get_or_register_bundle( NSBundle *bundle, NSString *path)
{
   NSBundle   *other;

   other = [registeredBundleInfo objectForKey:path];
   if( other)
      return( other);

   if( bundle)
   {
      if( ! registeredBundleInfo)
         registeredBundleInfo = [[NSMutableDictionary dictionary] retain];
      [registeredBundleInfo setObject:bundle
                            forKey:path];
#if DEBUG
      NSLog( @"Added Bundle %p for path \"%@\"", bundle, path);
#endif
   }
   return( bundle);
}


NSBundle  *(*NSBundleGetOrRegisterBundleWithPath)( NSBundle *bundle, NSString *path) = get_or_register_bundle;

+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( NO);
}


- (id) __mulleInitWithPath:(NSString *) fullPath
         sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo
{
   NSAutoreleasePool   *pool;
   NSFileManager       *manager;
   BOOL                isDir;
   BOOL                flag;

   self     = [self init];  // should be done by subcategory

   pool     = [NSAutoreleasePool new];

   fullPath = [fullPath stringByStandardizingPath];
   fullPath = [fullPath stringByResolvingSymlinksInPath];
   _path    = [fullPath copy];

   if( libInfo)
   {
      _executablePath = [libInfo->path copy];
      _startAddress   = libInfo->start;
      _endAddress     = libInfo->end;
   }

   manager = [NSFileManager defaultManager];
   flag    = [manager fileExistsAtPath:fullPath
                           isDirectory:&isDir];

   [pool release];

   //
   // bundles must be directories, except we allow a special extension
   // bundlefs

   //
   // But that doesn't work for the mainbundle...
   //
   //if( flag && ! isDir && ! [[self class] isBundleFilesystemExtension:[_path pathExtension]])
   //   flag = NO;

   if( ! flag)
   {
      [self release];
      return( nil);
   }

   return( self);
}


- (id) _mulleInitWithPath:(NSString *) fullPath
        sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo
{
   NSBundle   *bundle;

   if( ! [fullPath isAbsolutePath])
      MulleObjCThrowInvalidArgumentException( @"\"%@\" is not an absolute path", fullPath);

   // speculatively assume fullPath is already correct
   bundle = (*NSBundleGetOrRegisterBundleWithPath)( NULL, fullPath);
   if( bundle)
   {
      [bundle retain];
      [self release];
      return( bundle);
   }

   self = [self __mulleInitWithPath:fullPath
             sharedLibraryInfo:libInfo];
   if( ! self)
      return( self);

   return( (*NSBundleGetOrRegisterBundleWithPath)( self, _path));
}


//
// stage it, so that we can intercept it
//
- (instancetype) initWithPath:(NSString *) fullPath
{
   return( [self _mulleInitWithPath:fullPath
                  sharedLibraryInfo:NULL]);
}


- (void) finalize
{
   [self unloadBundle];

   [super finalize];
}


- (void) dealloc
{
   [_path release];
   [_executablePath release];
   [_resourcePath release];

   [super dealloc];
}


+ (NSBundle *) mainBundle
{
   NSBundle                         *bundle;
   NSString                         *path;
   struct _MulleObjCSharedLibrary   libInfo;

   libInfo.path  = [[NSProcessInfo processInfo] _executablePath];
   NSParameterAssert( [libInfo.path length]);
   libInfo.start = 0;
   libInfo.end   = 0;
   path          = [self _mainBundlePathForExecutablePath:libInfo.path];
   bundle        = [[[self alloc] _mulleInitWithPath:path
                                   sharedLibraryInfo:&libInfo] autorelease];
   return( bundle);
}


// a bundle is
//
// a) the main bundle
// b) anything loaded with NSBundle (except framework) is this true ??
//
//
// all shared libraries, except those listed under allBundles
//
static BOOL   haveDiscovered;

+ (NSDictionary *) mulleRegisteredBundleInfo
{
   NSBundle                        *bundle;
   NSString                        *path;
   NSString                        *mainExecutablePath;
   NSBundle                        *mainBundle;
   NSData                          *sharedLibraryInfo;
   struct _MulleObjCSharedLibrary  *infoLibs;
   struct _MulleObjCSharedLibrary  *sentinel;
   NSUInteger                      nInfoLibs;

   if( haveDiscovered)
      return( registeredBundleInfo);

   mainBundle         = [self mainBundle];
   assert( mainBundle);

   mainExecutablePath = [mainBundle executablePath];

   sharedLibraryInfo = [self _allSharedLibraries];
   infoLibs          = [sharedLibraryInfo bytes];
   nInfoLibs         = [sharedLibraryInfo length] / sizeof( struct _MulleObjCSharedLibrary);

   sentinel = &infoLibs[ nInfoLibs];
   while( infoLibs < sentinel)
   {
      path = [self _bundlePathForExecutablePath:infoLibs->path];

      // superflous check ?
      if( ! mainExecutablePath || ! [path isEqualToString:mainExecutablePath])
      {
         bundle = [[[NSBundle alloc] _mulleInitWithPath:path
                                      sharedLibraryInfo:infoLibs] autorelease];
         get_or_register_bundle( bundle, [bundle bundlePath]);
      }
      infoLibs++;
   }
   haveDiscovered = YES;

   return( registeredBundleInfo);
}


+ (NSArray *) _allBundlesWhichAreFrameworks:(BOOL) flag
{
   NSString         *path;
   NSMutableArray   *array;
   NSDictionary     *bundleInfo;

   bundleInfo = [self mulleRegisteredBundleInfo];

   array = [NSMutableArray array];
   for( path in bundleInfo)
      if( flag ^ ! [[path pathExtension] isEqualToString:@"framework"])
         [array addObject:[bundleInfo objectForKey:path]];
   return( array);
}


+ (NSArray *) allFrameworks
{
   return( [self _allBundlesWhichAreFrameworks:YES]);
}


+ (NSArray *) allBundles
{
   return( [self _allBundlesWhichAreFrameworks:NO]);
}


//
// could be a bottleneck in da future, then "just" make the
// bundle container a NSMapTable and index it with a second NSMapTable
// keyed by handle
//
+ (NSBundle *) _bundleForHandle:(void *) handle
{
   NSBundle       *bundle;

   for( bundle in [self allBundles])
      if( bundle->_handle == handle)
         return( bundle);
   return( nil);
}



+ (NSBundle *) bundleWithPath:(NSString *) path
{
   return( [[[self alloc] initWithPath:path] autorelease]);
}


+ (NSBundle *) _bundleWithPath:(NSString *) path
                executablePath:(NSString *) executablePath
{
   return( [[[self alloc] _mulleInitWithPath:path
                         executablePath:executablePath] autorelease]);
}


+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier
{
   NSEnumerator   *rover;
   NSString       *path;
   NSBundle       *bundle;
   NSDictionary   *bundleInfo;

   bundleInfo = [self mulleRegisteredBundleInfo];
   rover = [bundleInfo keyEnumerator];
   while( path = [rover nextObject])
   {
      bundle = [bundleInfo objectForKey:path];
      if( [identifier isEqualToString:[bundle bundleIdentifier]])
         return( bundle);
   }
   return( nil);
}


- (NSString *) resourcePath
{
   if( ! _resourcePath)
      _resourcePath = [[self _resourcePath] copy];
   return( _resourcePath);
}


- (NSString *) executablePath
{
   if( ! _executablePath)
      _executablePath = [[self _executablePath] copy];
   return( _executablePath);
}


- (NSString *) bundlePath
{
   return( _path);
}


- (BOOL) isLoaded;
{
   return( _handle != NULL);
}


- (void) willLoad
{
}


- (void) didLoad
{
}


- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension;
{
   NSString  *root;
   NSString  *path;

   root = [self resourcePath];
   path = [root stringByAppendingPathComponent:name];
   path = [path stringByAppendingPathExtension:extension];
   if( [[NSFileManager defaultManager] fileExistsAtPath:path])
      return( path);
   return( nil);
}


+ (NSArray *) _pathsWithExtension:(NSString *) extension
                      inDirectory:(NSString *) path
{
   NSFileManager           *manager;
   NSDirectoryEnumerator   *rover;
   NSMutableArray          *array;
   NSString                *file;
   NSAutoreleasePool       *pool;

   manager = [NSFileManager defaultManager];
   rover   = [manager enumeratorAtPath:path];
   if( ! rover)
      return( nil);

   array = [NSMutableArray array];

   pool = NSPushAutoreleasePool();
   while( file = [rover nextObject])
   {
      if( [[file pathExtension] isEqualToString:extension])
         [array addObject:[path stringByAppendingPathComponent:file]];
      [rover skipDescendants];  // do it always
   }
   NSPopAutoreleasePool( pool);

   return( array);
}


- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath
{
   NSString   *root;
   NSString   *path;

   root = [self resourcePath];
   path = root;
   if( subpath)
   {
      // search just here ?
      path = [root stringByAppendingPathComponent:subpath];
   }

   return( [NSBundle _pathsWithExtension:extension
                             inDirectory:path]);
}


// just guesses
+ (NSString *)  _OSIdentifier
{
   switch( [[NSProcessInfo processInfo] operatingSystem])
   {
   case NSWindowsNTOperatingSystem :
   case NSWindows95OperatingSystem : return( @"Windows");
   case NSSolarisOperatingSystem   : return( @"Solaris");
   case NSHPUXOperatingSystem      : return( @"HPUX");
   case NSDarwinOperatingSystem    : return( @"MacOS");
   case NSSunOSOperatingSystem     : return( @"SunOS");
   case NSOSF1OperatingSystem      : return( @"OSF1");
   case NSLinuxOperatingSystem     : return( @"Linux");
   case NSBSDOperatingSystem       : return( @"BSD");
   }
   return( @"???");
}


+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) executablePath
{
   // default, overridden by Darwin
   return( executablePath);
}


+ (NSString *) _bundlePathForExecutablePath:(NSString *) executablePath
{
   // default, overridden by Darwin
   return( executablePath);
}


- (Class) classNamed:(NSString *) className
{
   if( ! [self isLoaded])
      [self loadBundle];

   // THIS IS NOT CORRECT!
   return( NSClassFromString( className));
}


- (BOOL) mulleContainsAddress:(NSUInteger) address
{
   return( _startAddress >= address && _endAddress <= address);
}


//
// this is fallback code in case platform has no dladdr
//
+ (NSBundle *) bundleForClass:(Class) aClass
{
   NSDictionary                     *bundleInfo;
   NSBundle                         *bundle;
   NSUInteger                       classAddress;
   struct _MulleObjCSharedLibrary   libInfo;
   NSString                         *path;
   NSString                         *bundlePath;

   if( ! aClass)
      return( nil);

   classAddress = MulleObjCClassGetLoadAddress( aClass);
   assert( classAddress);

   //
   // it would be nice to binary search the bundles
   // but it doesn't seem worth to extract them into
   // an NSArray and sort them before searching here
   //
   bundleInfo = [self mulleRegisteredBundleInfo];
   for( bundlePath in bundleInfo)
   {
      bundle = [bundleInfo objectForKey:bundlePath];
      if( [bundle mulleContainsAddress:classAddress])
         return( bundle);
   }
   // assume all classes not in a shared library is part of a
   return( [NSBundle mainBundle]);
}


NSString   *MulleObjCBundleLocalizedStringFromTable( NSBundle *bundle,
                                                     NSString *tableName,
                                                     NSString *key,
                                                     NSString *value)
{
   NSCParameterAssert( [bundle isKindOfClass:[NSBundle class]]);

   return( [bundle localizedStringForKey:key
                                   value:value
                                   table:tableName]);
}

@end


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
static NSMutableDictionary  *_bundleDictionary;


static NSBundle  *get_or_register_bundle( NSBundle *bundle, NSString *path)
{
   NSBundle   *other;

   other = [_bundleDictionary objectForKey:path];
   if( other)
      return( other);

   if( bundle)
   {
      if( ! _bundleDictionary)
         _bundleDictionary = [NSMutableDictionary new];
      [_bundleDictionary setObject:bundle
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


- (instancetype) init
{
   abort();
   return( nil);
}


- (id) __initWithPath:(NSString *) fullPath
       executablePath:(NSString *) executablePath
{
   NSAutoreleasePool   *pool;
   NSFileManager       *manager;
   BOOL                isDir;
   BOOL                flag;

   self = [self init];  // be done by subcategory

   pool = [NSAutoreleasePool new];

   fullPath = [fullPath stringByStandardizingPath];
   fullPath = [fullPath stringByResolvingSymlinksInPath];
   _path    = [fullPath copy];

   _executablePath = [executablePath copy];

   manager = [NSFileManager defaultManager];
   flag    = [manager fileExistsAtPath:fullPath
                           isDirectory:&isDir];

   [pool release];

   //
   // bundles must be directories, except we allow a special extension
   // bundlefs
   //
   if( flag && ! isDir && ! [[self class] isBundleFilesystemExtension:[_path pathExtension]])
      flag = NO;

   if( ! flag)
   {
      [self release];
      return( nil);
   }

   return( self);
}


- (id) _initWithPath:(NSString *) fullPath
      executablePath:(NSString *) executablePath
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

   self = [self __initWithPath:fullPath
                executablePath:executablePath];
   if( ! self)
      return( self);

   return( (*NSBundleGetOrRegisterBundleWithPath)( self, _path));
}


//
// stage it, so that we can intercept it
//
- (instancetype) initWithPath:(NSString *) fullPath
{
   return( [self _initWithPath:fullPath
                executablePath:nil]);
}


- (void) finalize
{
   [self unload];

   [super finalize];
}


- (void) dealloc
{
   [_path release];
   [_executablePath release];

   [super dealloc];
}


+ (NSBundle *) mainBundle
{
   NSBundle   *bundle;
   NSString   *executablePath;
   NSString   *path;

   executablePath = [[NSProcessInfo processInfo] _executablePath];
   NSParameterAssert( [executablePath length]);

   path   = [self _mainBundlePathForExecutablePath:executablePath];
   bundle = [self _bundleWithPath:path
                   executablePath:executablePath];
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

+ (NSDictionary *) _bundleDictionary
{
   NSBundle   *bundle;
   NSArray    *executablePaths;
   NSString   *executablePath;
   NSString   *path;
   NSString   *mainExecutablePath;
   NSBundle   *mainBundle;

   if( haveDiscovered)
      return( _bundleDictionary);

   mainBundle         = [self mainBundle];
   mainExecutablePath = [mainBundle executablePath];

   executablePaths = [self _allImagePaths];
   for( executablePath in executablePaths)
   {
      path = [self _bundlePathForExecutablePath:executablePath];

      // superflous check ?
      if( [path isEqualToString:mainExecutablePath])
         continue;

      bundle = [[[NSBundle alloc] _initWithPath:path
                                 executablePath:executablePath] autorelease];
      get_or_register_bundle( bundle, [bundle bundlePath]);
   }
   haveDiscovered = YES;

   return( _bundleDictionary);
}


+ (NSArray *) _allBundlesWhichAreFrameworks:(BOOL) flag
{
   NSString         *path;
   NSMutableArray   *array;
   NSEnumerator     *rover;
   NSDictionary     *bundleInfo;

   bundleInfo = [self _bundleDictionary];

   array = [NSMutableArray array];
   rover = [bundleInfo keyEnumerator];
   while( path = [rover nextObject])
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
   NSEnumerator   *rover;
   NSBundle       *bundle;

   rover = [[self allBundles] objectEnumerator];
   while( bundle = [rover nextObject])
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
   return( [[[self alloc] _initWithPath:path
                         executablePath:executablePath] autorelease]);
}


+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier
{
   NSEnumerator   *rover;
   NSString       *path;
   NSBundle       *bundle;
   NSDictionary   *bundleInfo;

   bundleInfo = [self _bundleDictionary];
   rover = [bundleInfo keyEnumerator];
   while( path = [rover nextObject])
   {
      bundle = [bundleInfo objectForKey:path];
      if( [identifier isEqualToString:[bundle bundleIdentifier]])
         return( bundle);
   }
   return( nil);
}


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
- (NSString *) resourcePath
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

   pool  = NSPushAutoreleasePool();
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
      [self load];

   // THIS IS NOT CORRECT!
   return( NSClassFromString( className));
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


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

// other files in this library
#import "NSDirectoryEnumerator.h"
#import "NSFileManager.h"
#import "NSLog.h"
#import "NSProcessInfo.h"
#import "NSString+CString.h"
#import "NSString+PosixPathHandling.h"

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
   {
#if DEBUG   
      _NSPrintForDebugger( other); // höh ?
#endif      
      return( other);
   }
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


- (id) __initWithPath:(NSString *) fullPath
       executablePath:(NSString *) executablePath
{
   NSAutoreleasePool   *pool;
   NSFileManager       *manager;
   BOOL                isDir;
   BOOL                flag;
   
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
   if( flag && ! isDir && ! [isa isBundleFilesystemExtension:[_path pathExtension]])
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
      MulleObjCThrowInvalidArgumentException( fullPath, "not a absolute path");
      
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
- (id) initWithPath:(NSString *) fullPath
{
   return( [self _initWithPath:fullPath
                executablePath:nil]);
}



- (void) dealloc
{
   if( _handle)
      dlclose( _handle);

   NSAutoreleaseObject( _path);
   NSAutoreleaseObject( _executablePath);

   [super dealloc];
}


+ (NSBundle *) mainBundle
{
   NSBundle   *bundle;
   NSString   *path;
   NSArray    *arguments;
   
   arguments = [[NSProcessInfo processInfo] arguments];
   path      = [arguments objectAtIndex:0];
   NSParameterAssert( [path length]);
   
   bundle = [self _bundleWithPath:[self _mainBundlePathForExecutablePath:path]
                   executablePath:path];
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
   NSArray    *bundles;
   NSBundle   *bundle;
   
   if( haveDiscovered)
      return( _bundleDictionary);
      
   bundles = [self allImages];
   for( bundle in bundles)
      get_or_register_bundle( bundle, [bundle bundlePath]);

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
         [array addObject:[bundleInfo valueForKey:path]];
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


- (BOOL) load
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


- (BOOL) unload
{
   if( _handle)
      if( dlclose( _handle))
         MulleObjCThrowInternalInconsistencyException( @"dlcose: %s", dlerror());

   return( NO);
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


+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) path
{
   NSString   *dir;
   NSString   *architecture;

   // i hate calling this too often, so assume this is done but alss check
   NSParameterAssert( [path isEqualToString:[path stringByResolvingSymlinksInPath]]);
   
   dir          = [path stringByDeletingLastPathComponent];
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
+ (NSString *) _inferiorBundlePathForExecutablePath:(NSString *) path
{
   NSString   *dir;
   NSString   *fallback;
   
   // i hate calling this too often, so assume this is done but alss check
   NSParameterAssert( [path isEqualToString:[path stringByResolvingSymlinksInPath]]);

   dir          = [path stringByDeletingLastPathComponent];
   fallback     = dir;

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


- (Class) classNamed:(NSString *) className
{
   if( ! [self isLoaded])
      [self load];

   // THIS IS NOT CORRECT!
   return( NSClassFromString(className));
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



# pragma mark -
# pragma mark accessors into infoDictionary


@end


/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSBundle.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


//
// there will be subclasses for Frameworks proper
// and unix "spread" over multiple folders kinda bundles
//
@interface NSBundle : NSObject
{
   NSString       *_path;
   void           *_handle;
   NSUInteger     _startAddress;
   NSUInteger     _endAddress;
   NSLock         *_lock;  //used for lazy resources

   //
   // localization, we cach only for a single languageCode
   // because this is "usual"
   //
   NSString              *_languageCode;
   NSMutableDictionary   *_localizedStringTables;
   BOOL                  _isLoaded;

@private
   id             _infoDictionary;      // lazy can be NSNull

@private
   NSString       *_executablePath;  // for "already loaded" bundles
   NSString       *_resourcePath;    // for "already loaded" bundles
}


+ (BOOL) isBundleFilesystemExtension:(NSString *) extension;

+ (NSBundle *) mainBundle;
+ (NSArray *) allFrameworks;
+ (NSArray *) allBundles;
+ (NSBundle *) bundleWithPath:(NSString *) path;
+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier;

- (instancetype) initWithPath:(NSString *) fullPath;

- (NSString *) resourcePath;
- (NSString *) executablePath;
- (NSString *) bundlePath;
- (BOOL) isLoaded;


- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension;
- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
                   inDirectory:(NSString *) subpath;
- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath;

- (Class) classNamed:(NSString *) className;

- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) comment
                               table:(NSString *) tableName;

- (id) objectForInfoDictionaryKey:(NSString *) key;
- (NSDictionary *) infoDictionary;

@end


// stuff we need to implement
@interface NSBundle ( Missing)

- (NSString *) builtInPlugInsPath;

+ (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
                   inDirectory:(NSString *) bundlePath;

+ (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) bundlePath;

- (NSString *) pathForAuxiliaryExecutable:(NSString *) executableName;
- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath;
- (NSString *) privateFrameworksPath;
- (NSString *) sharedFrameworksPath;
- (NSString *) sharedSupportPath;

@end


// OS Specific stuff stuff we need to implement
@interface NSBundle ( OSSpecific)

// rename from load because of the wrong type
- (BOOL) loadBundle;
- (BOOL) unloadBundle;

//
// almost useless in statically linked configurations, because it will always
// be the mainBundle. Ideas: executable collects resources from libraries
// stores where ?
//
+ (NSBundle *) bundleForClass:(Class) aClass;

@end


extern NSString   *NSLoadedClasses;
extern NSString   *NSBundleDidLoadNotification;

NSString   *MulleObjCBundleLocalizedStringFromTable( NSBundle *bundle,
                                                     NSString *tableName,
                                                     NSString *key,
                                                     NSString *value);


#define NSLocalizedString( key, comment) \
   MulleObjCBundleLocalizedStringFromTable( [NSBundle mainBundle], nil, (key), @"")

#define NSLocalizedStringFromTable( key, table, comment) \
   MulleObjCBundleLocalizedStringFromTable( [NSBundle mainBundle], (table), (key), @"")

#define NSLocalizedStringFromTableInBundle( key, table, bundle, comment) \
   MulleObjCBundleLocalizedStringFromTable( (bundle), (table), (key), @"")

#define NSLocalizedStringWithDefaultValue( key, table, bundle, value, comment) \
   MulleObjCBundleLocalizedStringFromTable( (bundle), (table), (key), (value))


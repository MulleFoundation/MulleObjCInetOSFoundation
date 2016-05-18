/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import <MulleObjCFoundation/MulleObjCFoundation.h>



//
// there will be subclasses for Frameworks proper
// and unix "spread" over multiple folders kinda bundles
//
@interface NSBundle : NSObject
{
   NSString       *_path;
   void           *_handle;
   NSDictionary   *_infoDictionary;

@private
   NSString   *_executablePath;
}

- (id) initWithPath:(NSString *) fullPath;


+ (NSArray *) allBundles;
+ (NSArray *) allFrameworks;

+ (NSBundle *) bundleForClass:(Class) aClass;
+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier;
+ (NSBundle *) bundleWithPath:(NSString *) fullPath;
+ (NSBundle *) mainBundle;

+ (NSString *) pathForResource:(NSString *) name 
                        ofType:(NSString *) extension 
                   inDirectory:(NSString *) bundlePath;

+ (NSArray *) pathsForResourcesOfType:(NSString *) extension 
                          inDirectory:(NSString *) bundlePath;


- (NSString *) builtInPlugInsPath;
- (NSString *) bundlePath;
- (Class) classNamed:(NSString *) className;
- (NSString *) executablePath;

- (BOOL) isLoaded;
- (BOOL) load;
- (BOOL) unload;

- (id) objectForInfoDictionaryKey:(NSString *) key;
- (NSString *) pathForAuxiliaryExecutable:(NSString *) executableName;
- (NSString *) pathForResource:(NSString *) name 
                        ofType:(NSString *) extension;
- (NSString *) pathForResource:(NSString *) name 
                        ofType:(NSString *) extension
                   inDirectory:(NSString *)subpath;
- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath;
- (NSString *) privateFrameworksPath;
- (NSString *) resourcePath;
- (NSString *) sharedFrameworksPath;
- (NSString *) sharedSupportPath;

// 
+ (NSBundle *) _bundleWithPath:(NSString *) fullPath
                executablePath:(NSString *) executablePath;
- (id) _initWithPath:(NSString *) fullPath
      executablePath:(NSString *) executablePath;
+ (NSString *) _OSIdentifier;
+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) path;
+ (NSString *) _inferiorBundlePathForExecutablePath:(NSString *) path;

- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) comment
                               table:(NSString *) tableName;
@end


// more stuff should be in here
@interface NSBundle ( OSSpecific)

+ (NSString *) _mainExecutablePath;
+ (NSArray *) allImages;
- (NSDictionary *) infoDictionary;
- (Class) principalClass;
- (NSString *) bundleIdentifier;

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



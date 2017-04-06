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
#import "MulleObjCOSFoundationParents.h"



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
   NSString       *_executablePath;
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


- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath;

- (Class) classNamed:(NSString *) className;

@end


// stuff we need to implement
@interface NSBundle ( Missing)


- (NSString *) builtInPlugInsPath;
- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) comment
                               table:(NSString *) tableName;

+ (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
                   inDirectory:(NSString *) bundlePath;

+ (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) bundlePath;


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
- (NSString *) sharedFrameworksPath;
- (NSString *) sharedSupportPath;

@end


// OS Specific stuff stuff we need to implement
@interface NSBundle ( OSSpecific)

- (BOOL) load;
- (BOOL) unload;

+ (NSArray *) _allImagePaths;
- (NSDictionary *) infoDictionary;
- (Class) principalClass;
- (NSString *) bundleIdentifier;
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



//
//  NSBundle+Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 04.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

@interface NSBundle( Private)

+ (NSDictionary *) _bundleDictionary;
+ (NSArray *) _allBundlesWhichAreFrameworks:(BOOL) flag;
+ (NSBundle *) _bundleForHandle:(void *) handle;
+ (NSBundle *) _bundleWithPath:(NSString *) path
                executablePath:(NSString *) executablePath;

+ (NSArray *) _pathsWithExtension:(NSString *) extension
                      inDirectory:(NSString *) path;

+ (NSString *)  _OSIdentifier;
+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) executablePath;
+ (NSString *) _bundlePathForExecutablePath:(NSString *) executablePath;

- (id) __initWithPath:(NSString *) fullPath
       executablePath:(NSString *) executablePath;
- (id) _initWithPath:(NSString *) fullPath
      executablePath:(NSString *) executablePath;

- (NSString *) _executablePath;

- (void) willLoad;
- (void) didLoad;

@end


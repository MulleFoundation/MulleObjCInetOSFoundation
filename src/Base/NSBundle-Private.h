//
//  NSBundle-Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 04.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

struct _MulleObjCSharedLibrary 
{
   NSString     *path;
   NSUInteger   start;
   NSUInteger   end;   
};



@interface NSBundle( Private)

+ (NSDictionary *) _bundleDictionary;
+ (NSArray *) _allBundlesWhichAreFrameworks:(BOOL) flag;
+ (NSBundle *) _bundleForHandle:(void *) handle;

+ (NSArray *) _pathsWithExtension:(NSString *) extension
                      inDirectory:(NSString *) path;

+ (NSString *)  _OSIdentifier;
+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) executablePath;
+ (NSString *) _bundlePathForExecutablePath:(NSString *) executablePath;

- (id) __mulleInitWithPath:(NSString *) fullPath
    sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo;
- (id) _mulleInitWithPath:(NSString *) fullPath
    sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo;

- (NSString *) _executablePath;

- (BOOL) mulleContainsAddress:(NSUInteger) address;
+ (NSDictionary *) mulleRegisteredBundleInfo;

//
// Contains struct _MulleObjCSharedLibrary
// The number of contained structs can be determined by 
// [data length] / sizeof( struct _MulleObjCSharedLibrary)
// the string values inside it are autoreleased. Don't retain this data 
// EVER!
// possibly including main exe (dunno)
+ (NSData *) _allSharedLibraries;

- (void) willLoad;
- (void) didLoad;

@end


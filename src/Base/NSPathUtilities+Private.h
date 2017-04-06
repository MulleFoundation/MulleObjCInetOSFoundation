//
//  NSPathUtilities+Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

typedef struct
{
   NSString    *(*NSFullUserName)( void);
   NSString    *(*NSHomeDirectory)( void);
   NSString    *(*NSHomeDirectoryForUser)( NSString *);
   NSArray     *(*_NSSearchPathForDirectoriesInDomains)( NSSearchPathDirectory,
                                                        NSSearchPathDomainMask);
   NSString    *(*NSOpenStepRootDirectory)( void);
   NSString    *(*NSTemporaryDirectory)( void);
   NSString    *(*NSUserName)( void);
} _NSPathUtilityVectorTable;


// TODO: move this to foundation
extern _NSPathUtilityVectorTable   *_NSPathUtilityVectors;


//
// yep, a little root class
//
@interface _NSPathUtilityVectorTable_Loader
@end

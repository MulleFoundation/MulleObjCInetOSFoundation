/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSData+Posix.h is a part of MulleFoundation
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


enum
{
   NSDataReadingMappedIfSafe = 1UL << 0,
   NSDataReadingUncached     = 1UL << 1,
   NSDataReadingMappedAlways = 1UL << 3,
};
typedef NSUInteger   NSDataReadingOptions;



@interface NSData( OSBase)

+ (instancetype) dataWithContentsOfMappedFile:(NSString *) path;
+ (instancetype) dataWithContentsOfFile:(NSString *) path;

+ (instancetype) dataWithContentsOfURL:(NSURL *) url
                               options:(NSDataReadingOptions) options
                                 error:(NSError **) error;

+ (instancetype) dataWithContentsOfURL:(NSURL *) path;
- (instancetype) initWithContentsOfURL:(NSURL *) path;
- (BOOL) writeToURL:(NSURL *) path
         atomically:(BOOL) flag;

@end


@interface NSData( OSBaseFuture)

- (instancetype) initWithContentsOfFile:(NSString *) path;
- (instancetype) initWithContentsOfMappedFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag;

@end



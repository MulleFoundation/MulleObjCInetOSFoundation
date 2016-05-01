/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import <MulleObjCFoundation/MulleObjCFoundation.h>



enum {
   NSDataReadingMappedIfSafe = 1UL << 0,
   NSDataReadingUncached = 1UL << 1,
   NSDataReadingMappedAlways = 1UL << 3,
};
typedef NSUInteger NSDataReadingOptions;



@interface NSData( _Posix)

+ (id) dataWithContentsOfMappedFile:(NSString *) path;
+ (id) dataWithContentsOfFile:(NSString *) path;
- (id) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path 
          atomically:(BOOL) flag;


+ (instancetype) dataWithContentsOfURL:(NSURL *) url
                               options:(NSDataReadingOptions) options
                                 error:(NSError **) error;

+ (id) dataWithContentsOfURL:(NSURL *) path;
- (id) initWithContentsOfURL:(NSURL *) path;
- (BOOL) writeToURL:(NSURL *) path
         atomically:(BOOL) flag;

@end

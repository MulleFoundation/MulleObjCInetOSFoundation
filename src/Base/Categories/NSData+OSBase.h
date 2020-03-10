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
#import "import.h"


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
+ (instancetype) dataWithContentsOfFile:(NSString *) path
                                options:(NSDataReadingOptions) options
                                  error:(NSError **) error;

@end


@interface NSData( OSBaseFuture)

- (instancetype) initWithContentsOfFile:(NSString *) path;

// prefer this and query current error afterwards
- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag;

- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
               error:(NSError **) error;

@end



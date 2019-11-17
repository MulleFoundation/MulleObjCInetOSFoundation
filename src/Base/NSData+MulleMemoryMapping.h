/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager.h is a part of MulleFoundation
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



@interface NSData( MulleMemoryMapping)

- (instancetype) initWithContentsOfMappedFile:(NSString *) path;
+ (instancetype) dataWithContentsOfMappedFile:(NSString *) path;

@end


@interface NSMutableData( MulleMemoryMapping)

- (instancetype) initWithContentsOfMappedFile:(NSString *) path;

@end

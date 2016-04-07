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


@interface NSData( _Posix)

+ (id) dataWithContentsOfFile:(NSString *) path;
- (id) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path 
          atomically:(BOOL) flag;

@end

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSArray+Posix_Private.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import <MulleObjCFoundation/MulleObjCFoundation.h>


@interface NSArray( Posix_Private)

// don't access argv and argv contents afterwards(!), do not free it 
+ (NSArray *) _newWithArgc:(int) argc
                argvNoCopy:(char **) argv;
                
@end

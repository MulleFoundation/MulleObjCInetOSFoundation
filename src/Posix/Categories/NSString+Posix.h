/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSString+Posix.h is a part of MulleFoundation
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


@interface NSString( Posix)

+ (id) stringWithContentsOfFile:(NSString *) path;
- (id) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path 
          atomically:(BOOL) flag;


//+ (id) stringWithContentsOfFile:(NSString *) path 
//                       encoding:(NSUInteger) arg2 
//                          error:(id *) arg3;
//+ (id) stringWithContentsOfFile:(NSString *) path 
//                   usedEncoding:(NSUInteger *) arg2 
//                          error:(id *) arg3;
//- (id) initWithContentsOfFile:(id) arg1 
//                     encoding:(NSUInteger) arg2 
//                        error:(id *) arg3;
//- (id) initWithContentsOfFile:(NSString *) path 
//                 usedEncoding:(NSUInteger *) arg2 
//                        error:(id *) arg3;
//- (BOOL) writeToFile:(NSString *) path 
//          atomically:(BOOL) flag 
//            encoding:(NSUInteger) arg3 
//               error:(id *) arg4;


@end

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask+System.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__ 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTask.h"


// just so convenient...

@interface NSTask( _System)

+ (NSString *) _systemWithString:(NSString *) s
                workingDirectory:(NSString *) dir;
+ (NSString *) _system:(NSArray *) argv
      workingDirectory:(NSString *) dir;                
@end

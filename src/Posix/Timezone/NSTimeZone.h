/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSTimeZone.h is a part of MulleFoundation
 *
 *  Copyright (C)  2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import <MulleObjCFoundation/MulleObjCFoundation.h>


@class NSArray;
@class NSData;
@class NSString;
@class NSDictionary;

//
// this class is not functional on its own. Categories must implement
// all methods defined in NSTimeZone+_Abstract
// and all methods declared in NSTimeZone+_Abstract_NSDate
// 
@interface NSTimeZone : NSObject <NSCopying> 
{
   NSString   *name_;
   NSData     *data_;
}

// Primary creation method is +timeZoneWithName:; the
// data-taking variants should rarely be used directly

+ (id) timeZoneWithName:(NSString *) name;
+ (id) timeZoneWithName:(NSString *) name 
                   data:(NSData *) data;

- (id) initWithName:(NSString *) name;
- (id) initWithName:(NSString *) name 
               data:(NSData *) data;

// Time zones created with this never have daylight savings and the
// offset is constant no matter the date; the name and abbreviation
// do NOT follow the Posix convention (of minutes-west).
+ (id) timeZoneWithAbbreviation:(NSString *) abbreviation;

- (NSString *) name;
- (NSData *) data;

+ (NSTimeZone *) systemTimeZone;
+ (void) resetSystemTimeZone;

+ (NSTimeZone *) defaultTimeZone;
+ (void) setDefaultTimeZone:(NSTimeZone *) tz;

+ (NSTimeZone *) localTimeZone;
+ (NSDictionary *) abbreviationDictionary;

- (NSString *) abbreviation;
- (id) description;

- (BOOL) isEqualToTimeZone:(NSTimeZone *) tz;

@end


@interface NSTimeZone( _Abstract)

- (id) initWithName:(NSString *) name;
+ (NSTimeZone  *) _uncachedSystemTimeZone;
+ (NSArray *) knownTimeZoneNames;
+ (NSDictionary *) abbreviationDictionary;

@end



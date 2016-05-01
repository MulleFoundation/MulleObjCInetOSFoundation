/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSLocale.h is a part of MulleFoundation
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


@interface NSLocale ( Posix)

+ (id) systemLocale;
+ (id) currentLocale;

+ (NSArray *) availableLocaleIdentifiers;
+ (NSArray *) ISOLanguageCodes;
+ (NSArray *) ISOCountryCodes;
+ (NSArray *) ISOCurrencyCodes;

+ (NSString *) canonicalLocaleIdentifierFromString:(NSString *) string;
+ (NSString *) canonicalLanguageIdentifierFromString:(NSString *) string;

- (id) initWithLocaleIdentifier:(NSString *) string;
- (NSString *) localeIdentifier;  

- (id) objectForKey:(id) key;
- (NSString *) displayNameForKey:(id) key 
                           value:(id) value;

@end


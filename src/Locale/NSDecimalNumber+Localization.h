/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSDecimalNumber+Localization.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCLocalizationFoundationParentIncludes.h"


@interface NSDecimalNumber( _Localization)

- (id) initWithString:(NSString *) numberValue 
              locale:(id) locale;

+ (NSDecimalNumber *) decimalNumberWithString:(NSString *) numberValue 
                                       locale:(id) locale;

- (NSString *) descriptionWithLocale:(id) locale;

@end

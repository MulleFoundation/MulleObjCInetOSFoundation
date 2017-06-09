//
//  NSDate+NSUserDefaults.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 13.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#import "MulleObjCOSFoundationParents.h"

#import "NSUserDefaults.h"


@interface NSCalendarDate( NSUserDefaults)

+ (instancetype) _calendarDateWithNaturalLanguageString:(NSString *) string
                                                 locale:(id) locale
                                  referenceCalendarDate:(NSCalendarDate *) today;

// naming for compatibility
+ (instancetype) dateWithNaturalLanguageString:(NSString *) string
                                        locale:(id) locale;
+ (instancetype) dateWithNaturalLanguageString:(NSString *) string;

@end


// backwards comp.
@interface NSDate( NSUserDefaults)

+ (instancetype) dateWithNaturalLanguageString:(NSString *) string
                                        locale:(id) locale;
+ (instancetype) dateWithNaturalLanguageString:(NSString *) string;

@end

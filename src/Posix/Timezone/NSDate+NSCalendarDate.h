//
//  NSDate+NSCalendarDate.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 10.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjCFoundation/MulleObjCFoundation.h>


@class NSCalendarDate;

@interface NSDate (NSCalendarDate)

+ (instancetype) dateWithString:(NSString *) aString;
+ (instancetype) dateWithNaturalLanguageString:(NSString *) string
                                        locale:(id) locale;
+ (instancetype) dateWithNaturalLanguageString:(NSString *) string;

- (instancetype) initWithString:(NSString *) description;

- (NSCalendarDate *)dateWithCalendarFormat:(NSString *) format
                                  timeZone:(NSTimeZone *) aTimeZone;
- (NSString *) descriptionWithCalendarFormat:(NSString *) format
                                    timeZone:(NSTimeZone *) aTimeZone
                                      locale:(id) locale;

@end

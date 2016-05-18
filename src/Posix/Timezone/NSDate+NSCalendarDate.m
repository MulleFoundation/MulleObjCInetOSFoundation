//
//  NSDate+NSCalendarDate.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 10.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "NSDate+NSCalendarDate.h"

// other files in this library
#import "NSCalendarDate.h"

// std-c and dependencies


//
// TODO: put the formatter in a cvar and don't regenerate him all the time
//
static NSString   *NSDateDefaultFormat = @"%Y-%m-%d %H:%M:%S %z";

@implementation NSDate (NSCalendarDate)

+ (instancetype) dateWithString:(NSString *) s
{
   NSDateFormatter   *formatter;

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:NSDateDefaultFormat
    allowNaturalLanguage:NO] autorelease];
   return( [formatter dateFromString:s]);
}


// lame code, fix later
- (instancetype) initWithString:(NSString *) s
{
   [self release];
   return( [[isa dateWithString:s] retain]);
}



+ (instancetype) dateWithNaturalLanguageString:(NSString *) s
                                        locale:(id) locale
{
   NSDateFormatter   *formatter;

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:NSDateDefaultFormat
                                       allowNaturalLanguage:YES] autorelease];
   [formatter setLocale:locale];
   return( [formatter dateFromString:s]);
}


+ (instancetype) dateWithNaturalLanguageString:(NSString *) s
{
   NSDateFormatter   *formatter;

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:NSDateDefaultFormat
                                       allowNaturalLanguage:YES] autorelease];
   return( [formatter dateFromString:s]);
}



- (NSCalendarDate *) dateWithCalendarFormat:(NSString *) format
                                   timeZone:(NSTimeZone *) tz
{
   NSCalendarDate   *date;

   date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
   [date setCalendarFormat:format];
   [date setTimeZone:tz];
   return( date);
}


- (NSString *) descriptionWithCalendarFormat:(NSString *) format
                                    timeZone:(NSTimeZone *) tz
                                      locale:(id) locale
{
   NSDateFormatter   *formatter;

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:format
                                       allowNaturalLanguage:YES] autorelease];
   [formatter setTimeZone:tz];
   [formatter setLocale:locale];
   return( [formatter stringFromDate:self]);
}

@end

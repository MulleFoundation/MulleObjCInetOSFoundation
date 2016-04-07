//
//  MulleTimeZone.m
//  NSTimeZone
//
//  Created by Nat! on 19.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSTimeZone+Posix.h"


@implementation NSTimeZone( Posix)

- (id) initWithName:(NSString *) name
{   
   extern void   *mulle_tz_context_with_name( char *, size_t *);
   size_t     size;
   void       *info;
   
   NSParameterAssert( [name isKindOfClass:[NSString class]]);
   
   [self init];

   info = mulle_tz_context_with_name( (char *) [name cString], &size);
   if( ! info)
   {
      [self release];
      return( nil);
   }
      
   data_ = [[NSData alloc] initWithBytesNoCopy:info
                                        length:size
                                  freeWhenDone:YES];
   name_ = [name copy];

   return( self);
}


+ (NSTimeZone  *) _uncachedSystemTimeZone
{
   NSString  *name;
   char      *s;

   s = getenv( "TZ");
   if( ! s)
      s = "GMT";

   name = [NSString stringWithCString:s];
   
   return( [NSTimeZone timeZoneWithName:name]);
}


+ (NSArray *) knownTimeZoneNames
{
   extern char   *mulle_get_timezone_zone_tab_file( void);
   NSMutableArray   *names;
   NSArray          *entries;
   NSEnumerator     *rover;
   NSString         *filename;
   NSString         *zonesString;
   NSString         *line;
   NSString         *name;
   NSArray          *zonesLines;
   char             *s;
   
   names = [NSMutableArray array];
   
   s           = mulle_get_timezone_zone_tab_file();
   filename    = [NSString stringWithCString:s];
   zonesString = [NSString stringWithContentsOfFile:filename];
   
   zonesLines  = [zonesString componentsSeparatedByString:@"\n"];
   
   rover = [zonesLines objectEnumerator];
   while( line = [rover nextObject])
   {
      if( [line hasPrefix:@"#"])
         continue;
      entries = [line componentsSeparatedByString:@"\t"];
      if( [entries count] < 3)
         continue;
      name = [entries objectAtIndex:2];
      [names addObject:name];
   }
   
   return( names);
}


+ (NSDictionary *) abbreviationDictionary
{
   static struct  
   {
      char   *abr;
      char   *name;
   } lut[] =
   {
   { "ADT", "America/Halifax" },
   { "AKDT", "America/Juneau" },
   { "AKST", "America/Juneau" },
   { "ART", "America/Argentina/Buenos_Aires" },
   { "AST", "America/Halifax" },
   { "BDT", "Asia/Dhaka" },
   { "BRST", "America/Sao_Paulo" },
   { "BRT", "America/Sao_Paulo" },
   { "BST", "Europe/London" },
   { "CAT", "Africa/Harare" },
   { "CDT", "America/Chicago" },
   { "CEST", "Europe/Paris" },
   { "CET", "Europe/Paris" },
   { "CLST", "America/Santiago" },
   { "CLT", "America/Santiago" },
   { "COT", "America/Bogota" },
   { "CST", "America/Chicago" },
   { "EAT", "Africa/Addis_Ababa" },
   { "EDT", "America/New_York" },
   { "EEST", "Europe/Istanbul" },
   { "EET", "Europe/Istanbul" },
   { "EST", "America/New_York" },
   { "GMT", "GMT" },
   { "GST", "Asia/Dubai" },
   { "HKT", "Asia/Hong_Kong" },
   { "HST", "Pacific/Honolulu" },
   { "ICT", "Asia/Bangkok" },
   { "IRST", "Asia/Tehran" },
   { "IST", "Asia/Calcutta" },
   { "JST", "Asia/Tokyo" },
   { "KST", "Asia/Seoul" },
   { "MDT", "America/Denver" },
   { "MSD", "Europe/Moscow" },
   { "MSK", "Europe/Moscow" },
   { "MST", "America/Denver" },
   { "NZDT", "Pacific/Auckland" },
   { "NZST", "Pacific/Auckland" },
   { "PDT", "America/Los_Angeles" },
   { "PET", "America/Lima" },
   { "PHT", "Asia/Manila" },
   { "PKT", "Asia/Karachi" },
   { "PST", "America/Los_Angeles" },
   { "SGT", "Asia/Singapore" },
   { "UTC", "UTC" },
   { "WAT", "Africa/Lagos" },
   { "WEST", "Europe/Lisbon" },
   { "WET", "Europe/Lisbon" },
   { "WIT", "Asia/Jakarta" },
   { 0, 0 } 
   };
   
   NSMutableDictionary   *dict;
   unsigned int   i;
   NSString       *value;
   NSString       *key;

   dict = [NSMutableDictionary dictionary];
   
   for( i = 0; lut[ i].abr; i++)
   {
      key   = [NSString stringWithCString:lut[ i].abr];
      value = [NSString stringWithCString:lut[ i].name];
      [dict setObject:value
               forKey:key];
   }
   return( dict);
}


- (NSInteger) secondsFromGMT
{
   return( [self secondsFromGMTForDate:[NSDate date]]);
}


- (NSInteger) secondsFromGMTForDate:(NSDate *) aDate
{
   extern long      mulle_get_gmt_offset_for_time_interval( void *, time_t);
   NSTimeInterval   seconds;
   long             offset;
   
   seconds = [aDate timeIntervalSince1970]; // standard unix
   offset  = mulle_get_gmt_offset_for_time_interval( [data_ bytes], (time_t) seconds);
   return( offset);
}


- (NSString *) abbreviationForDate:(NSDate *) aDate
{
   extern char      *mulle_get_abbreviation_for_time_interval( void *, time_t);
   NSTimeInterval   seconds;
   char             *abr;
   
   seconds = [aDate timeIntervalSince1970]; // standard unix
   abr     = mulle_get_abbreviation_for_time_interval( [data_ bytes], (time_t) seconds);
   return( [NSString stringWithCString:abr]);
}


- (BOOL) isDaylightSavingTimeForDate:(NSDate *) aDate
{
   extern int       mulle_get_daylight_saving_flag_for_time_interval( void *, time_t);
   NSTimeInterval   seconds;
   int              flag;
   
   seconds = [aDate timeIntervalSince1970]; // standard unix
   flag    = mulle_get_daylight_saving_flag_for_time_interval( [data_ bytes], (time_t) seconds);
   return( flag ? YES : NO);
}


+ (id) timeZoneForSecondsFromGMT:(NSInteger) seconds;
{
   if( ! seconds)
      return( [self timeZoneWithAbbreviation:@"GMT"]);

   abort();
   return( nil);
}


- (NSString *) abbreviation
{
   return( [self abbreviationForDate:[NSDate date]]);
}


- (BOOL) isDaylightSavingTime
{
   return( [self isDaylightSavingTimeForDate:[NSDate date]]);
}

@end

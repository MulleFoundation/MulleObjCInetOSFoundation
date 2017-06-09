//
//  NSDate+NSUserDefaults.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 13.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "NSCalendarDate+NSUserDefaults.h"


@interface NSCalendarDate( Private)

- (struct mulle_mini_tm) _miniTM;

@end

@interface NSObject( FoundationPrivate)

- (BOOL) __isNSNumber;

@end


@implementation NSCalendarDate( NSUserDefaults)

+ (instancetype) dateWithNaturalLanguageString:(NSString *) s
{
   NSDictionary   *dictionary;
   
   dictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
   return( [self dateWithNaturalLanguageString:s
                                        locale:dictionary]);
}


#pragma mark - these routines are supposed to use heuristics

//static NSString   *NSNaturalLanguageDefaultFormat = @"%m/%d/%Y %H:%M:%S";

NSString  *NSEarlierTimeDesignationsKey   = @"NSEarlierTimeDesignations";
NSString  *NSLaterTimeDesignationsKey     = @"NSLaterTimeDesignations";
NSString  *NSNextDayDesignationsKey       = @"NSNextDayDesignations";
NSString  *NSNextNextDayDesignationsKey   = @"NSNextNextDayDesignations";
NSString  *NSPriorDayDesignationsKey      = @"NSPriorDayDesignations";
NSString  *NSThisDayDesignationsKey       = @"NSThisDayDesignations";

NSString  *NSHourNameDesignationsKey      = @"NSHourNameDesignations";

NSString  *NSDateTimeOrderingKey          = @"NSDateTimeOrdering";

NSString  *NSAMPMDesignationKey           = @"NSAMPMDesignation";
NSString  *NSYearMonthWeekDesignationsKey = @"NSYearMonthWeekDesignations";
NSString  *NSMonthNameArrayKey            = @"NSMonthNameArray";
NSString  *NSShortMonthNameArrayKey       = @"NSShortMonthNameArray";
NSString  *NSShortWeekDayNameArrayKey     = @"NSShortWeekDayNameArray";
NSString  *NSWeekDayNameArrayKey          = @"NSWeekDayNameArray";

// format strings
NSString  *NSDateFormatStringKey          = @"NSDateFormatString";
NSString  *NSShortDateFormatStringKey     = @"NSShortDateFormatString";
NSString  *NSShortTimeDateFormatStringKey = @"NSShortTimeDateFormatString";
NSString  *NSTimeDateFormatStringKey      = @"NSTimeDateFormatString";
NSString  *NSTimeFormatStringKey          = @"NSTimeFormatString";


static NSString  *NSAMString    = @"am";
static NSString  *NSPMString    = @"pm";
static NSString  *NSYearString  = @"year";
static NSString  *NSMonthString = @"month";
static NSString  *NSWeekString  = @"week";

static NSString  *NSSundayString    = @"sun";
static NSString  *NSMondayString    = @"mon";
static NSString  *NSTuesdayString   = @"tue";
static NSString  *NSWednesdayString = @"wed";
static NSString  *NSThursdayString  = @"thu";
static NSString  *NSFridayString    = @"fri";
static NSString  *NSSaturdayString  = @"sat";

static NSString  *NSJanuaryString   = @"jan";
static NSString  *NSFebruaryString  = @"feb";
static NSString  *NSMarchString     = @"mar";
static NSString  *NSAprilString     = @"apr";
static NSString  *NSMayString       = @"may";
static NSString  *NSJuneString      = @"jun";
static NSString  *NSJulyString      = @"jul";
static NSString  *NSAugustString    = @"aug";
static NSString  *NSSeptemberString = @"sep";
static NSString  *NSOctoberString   = @"oct";
static NSString  *NSNovemberString  = @"nov";
static NSString  *NSDecemberString  = @"dec";


// straight substitutions of words to a single string
static NSString   *substitutions[ 7 + 1];
static NSString   *months[ 12];
static NSString   *weekdays[ 7];

+ (void) load
{
   unsigned int   i;
  
   i = 0;
   substitutions[ i++] = NSEarlierTimeDesignationsKey;
   substitutions[ i++] = NSLaterTimeDesignationsKey;
   substitutions[ i++] = NSNextDayDesignationsKey;
   substitutions[ i++] = NSNextNextDayDesignationsKey;
   substitutions[ i++] = NSPriorDayDesignationsKey;
   substitutions[ i++] = NSThisDayDesignationsKey;
   substitutions[ i++] = 0;
   
   assert( i == 7);
   
   i = 0;
   months[ i++] = NSJanuaryString;
   months[ i++] = NSFebruaryString;
   months[ i++] = NSMarchString;
   months[ i++] = NSAprilString;
   months[ i++] = NSMayString;
   months[ i++] = NSJuneString;
   months[ i++] = NSJulyString;
   months[ i++] = NSAugustString;
   months[ i++] = NSSeptemberString;
   months[ i++] = NSOctoberString;
   months[ i++] = NSNovemberString;
   months[ i++] = NSDecemberString;

   assert( i == 12);
   
   i = 0;
   weekdays[ i++] = NSSundayString;
   weekdays[ i++] = NSMondayString;
   weekdays[ i++] = NSTuesdayString;
   weekdays[ i++] = NSWednesdayString;
   weekdays[ i++] = NSThursdayString;
   weekdays[ i++] = NSFridayString;
   weekdays[ i++] = NSSaturdayString;

   assert( i == 7);
}

static NSUInteger   find_word( NSMutableArray *components,
                               NSString *word)
{
   NSUInteger   i;
   NSString     *component;
   
   i = 0;
   for( component in components)
   {
      if( [word compare:component
                options:NSCaseInsensitiveSearch|NSLiteralSearch] == NSOrderedSame)
         return( i);
      ++i;
   }
   return( NSNotFound);
}


static void   substitute_word( NSMutableArray *components,
                               NSString *word,
                               NSString *replacement)
{
   NSUInteger   i;
   NSString     *component;
   
   i = 0;
   for( component in components)
   {
      if( [word compare:component
                options:NSCaseInsensitiveSearch|NSLiteralSearch] == NSOrderedSame)
         [components replaceObjectAtIndex:i
                               withObject:replacement];
      ++i;
   }
}


static void  substitute_months( NSMutableArray *components, NSArray *words)
{
   unsigned int   i;
   
   if( ! words)
      return;
   
   if( [words count] != 12)
      MulleObjCThrowCInvalidArgumentException( "weekday names must contain 12 and only 12 strings");
   
   for( i = 0; i < 12; i++)
      substitute_word( components, [words :i], months[ i]);
}


static void  substitute_weekdays( NSMutableArray *components, NSArray *words)
{
   unsigned int  i;
   
   if( ! words)
      return;
   
   if( [words count] != 7)
      MulleObjCThrowCInvalidArgumentException( "weekday names must contain seven and only seven strings");
   
   for( i = 0; i < 7; i++)
      substitute_word( components, [words :i], weekdays[ i]);
}


static void  substitute_ampm( NSMutableArray *components, NSArray *words)
{
   if( ! words)
      return;

   if( [words count] != 2)
      MulleObjCThrowCInvalidArgumentException( "AM/PM designation must contain two and only two strings");
   
   substitute_word( components, [words :0], NSAMString);
   substitute_word( components, [words :1], NSPMString);
}


static void  substitute_yearmonthweek( NSMutableArray *components, NSArray *words)
{
   if( ! words)
      return;
   
   if( [words count] != 3)
      MulleObjCThrowCInvalidArgumentException( "year/month/week designation must contain three and only three strings");
   
   substitute_word( components, [words :0], NSYearString);
   substitute_word( components, [words :1], NSMonthString);
   substitute_word( components, [words :2], NSWeekString);
}


static void   substitute_hours_with_houroffsets( NSMutableArray *components, NSArray *words)
{
   NSUInteger   i, n;
   
   if( ! words)
      return;
   
   n = [words count];
   if( n < 2)
      MulleObjCThrowCInvalidArgumentException( "hours designation must contain at least two entries");

   for( i = 1; i < n; i++)
      if( find_word( components, [words :i]))
         substitute_word( components, [words :i], [words :0]); // should ne nsnumber
}


static int   index_of_month( NSString *key)
{
   int   i;
   
   for( i = 0; i < 12; i++)
      if( key == months[ i])
         return( i);
   return( -1);
}


static int   index_of_weekday( NSString *key)
{
   int   i;
   
   for( i = 0; i < 12; i++)
      if( key == weekdays[ i])
         return( i);
   return( -1);
}


static int  hour_offset( NSString *key)
{
   if( key == NSNextDayDesignationsKey)
      return( 24 * 60 * 60);
   if( key == NSNextNextDayDesignationsKey)
      return( 2 * 24 * 60 * 60);
   if( key == NSPriorDayDesignationsKey)
      return( -1 * 24 * 60 * 60);
   if( key == NSThisDayDesignationsKey)
      return( 0);
   return( -1);
}


// postive means "next", negative means "previous"
struct _mulle_date_offset
{
   union
   {
      struct
      {
         unsigned int  year          : 1;
         unsigned int  month         : 1;
         unsigned int  week          : 1;
         unsigned int  weekday       : 1;
         unsigned int  day           : 1;
         unsigned int  hour          : 1;
         unsigned int  named_month   : 1;
         unsigned int  named_weekday : 1;
         unsigned int  named_hour    : 1;
      } flags;
      unsigned int  bits;
   };

   int   year_offset;
   int   month_offset;
   int   week_offset;
   int   weekday_offset;  // 0-6 (Sunday = 0)
   int   day_offset;
   int   hour_offset;
   
   int   named_month_offset;
   int   named_weekday_offset;
   int   named_hour_offset;
};


struct context
{
   NSInteger        year_diff;
   NSInteger        month_diff;
   NSInteger        day_diff;
   NSInteger        hour_diff;
   NSInteger        abs_month;
   NSInteger        abs_year;
   NSInteger        abs_day;
   NSInteger        abs_hour;
};

- (NSCalendarDate *) _calendarDateWithDateOffsets:(struct _mulle_date_offset *) offsets
{
   NSCalendarDate   *date;
   struct context   ctx;
   
   if( ! offsets->bits)
      return( self);

   memset( &ctx, 0, sizeof( ctx));
   
   // get absoute andn next year happening first
   date = self;
   
   ctx.year_diff  = offsets->year_offset;
   ctx.month_diff = offsets->month_offset;
   ctx.day_diff   = offsets->day_offset;
   ctx.hour_diff  = offsets->hour_offset;
   
   //
   // get current weekday
   // dial to previous or next
   // depends where sunday is really, but...
   //
   if( offsets->flags.named_month)
   {
      assert( ! offsets->flags.month);
      if( offsets->named_month_offset < 0)
      {
         ctx.month_diff -= 12 + [date monthOfYear];
         ctx.abs_month   = -offsets->named_month_offset;
      }
      else
      {
         ctx.month_diff += 12 - [date monthOfYear];
         ctx.abs_month   = offsets->named_month_offset;
      }
   }
   
   if( offsets->flags.named_weekday)
   {
      assert( ! offsets->flags.day);
      if( offsets->named_weekday_offset < 0)
      {
         ctx.day_diff  -= 7 + [date dayOfWeek];
         ctx.abs_day    = -offsets->named_weekday_offset;
      }
      else
      {
         ctx.day_diff  += 7 - [date dayOfWeek];
         ctx.abs_day    = offsets->named_weekday_offset;
      }
   }

   if( offsets->flags.named_hour)
   {
      assert( ! offsets->flags.hour);
      if( offsets->named_hour_offset < 0)
      {
         ctx.day_diff -= 1;
         ctx.abs_hour  = offsets->named_hour_offset;
      }
      else
      {
         ctx.day_diff += 1;
         ctx.abs_hour  = offsets->named_hour_offset;
      }
   }

   if( ctx.year_diff || ctx.month_diff || ctx.day_diff || ctx.hour_diff)
      date = [date dateByAddingYears:ctx.year_diff
                              months:ctx.month_diff
                                days:ctx.day_diff
                               hours:ctx.hour_diff
                             minutes:0
                             seconds:0];

   if( ctx.abs_month || ctx.abs_hour || ctx.abs_day)
   {
      // todo: use minitm!
      date = [NSCalendarDate dateWithYear:[date yearOfCommonEra]
                                    month:ctx.abs_month ? ctx.abs_month : [date monthOfYear]
                                      day:ctx.abs_day ? ctx.abs_day : [date dayOfMonth]
                                     hour:ctx.abs_hour ? ctx.abs_hour : [date hourOfDay]
                                   minute:[date minuteOfHour]
                                   second:[date secondOfMinute]
                                 timeZone:[date timeZone]];
   }
   return( date);
}

//
// we take the string split it into components
// then substitute found strings with fixed strings
// which makes things easier

enum date_kind
{
   is_unknown = -1,
   is_relative = 1,
   is_absolute = 2
};


+ (instancetype) _calendarDateWithNaturalLanguageString:(NSString *) s
                                                 locale:(id) locale
                                  referenceCalendarDate:(NSCalendarDate *) now
{
   NSArray                     *array;
   NSArray                     *arrays;
   NSArray                     *words;
   NSCalendarDate              *date;
   NSMutableArray              *components;
   NSString                    **p;
   NSString                    *word;
   NSUInteger                  len;
   NSInteger                   value;
   char                        *s_ordering;
   char                        buf[ 8];
   enum date_kind              kind;
   int                         i;
   int                         multiplier;
   struct _mulle_date_offset   relative;
   struct mulle_mini_tm        tm;
   
   //
   // get string into components, only care about a-z and 0-9
   //
   components = [NSMutableArray array];
   array = [s _componentsSeparatedByCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
   if( array)
      [components addObject:s];
   else
      [components addObjectsFromArray:array];

   // now make "easy substitutions" (sorta tokenizing)
   for( p = substitutions; *p; p++)
   {
      words = [locale objectForKey:*p];
      if( ! words)
         continue;
      
      for( word in words)
         substitute_word( components, word, *p);
   }

   // tokenize am/pm
   words = [locale objectForKey:NSAMPMDesignationKey];
   substitute_ampm( components, words);

   // tokenize week/month/year
   words = [locale objectForKey:NSYearMonthWeekDesignationsKey];
   substitute_yearmonthweek( components, words);

   // tokenize week days
   words = [locale objectForKey:NSWeekDayNameArrayKey];
   substitute_weekdays( components, words);

   // tokenize long week days
   words = [locale objectForKey:NSShortWeekDayNameArrayKey];
   substitute_weekdays( components, words);

   // tokenize months
   words = [locale objectForKey:NSShortMonthNameArrayKey];
   substitute_months( components, words);

   // tokenize long months
   words = [locale objectForKey:NSMonthNameArrayKey];
   substitute_months( components, words);

   // convert hours to a date string
   arrays = [locale objectForKey:NSHourNameDesignationsKey];
   for( array in arrays)
      substitute_hours_with_houroffsets( components, array);

   //
   // now what is left is
   // unintelligible words:
   // known words
   // NSNumbers for hours
   // strings matching one of the formatters
   // NSShortDateFormatStringKey, NSShortTimeDateFormatStringKey,
   // NSTimeDateFormatStringKey NSTimeFormatStringKey
   //
   
   // let's assume that the starting date is "now"
   strcpy( buf, "MDYHms");
   s_ordering = [[locale objectForKey:NSDateTimeOrderingKey] UTF8String];
   if( s_ordering)
   {
      len = strlen( s_ordering);
      if( len > 4)
         len = 4;
      memcpy( buf, s_ordering, len);
   }
   
   memset( &relative, 0, sizeof( relative));
   if( ! now)
      now = [NSCalendarDate calendarDate];
   tm  = [now _miniTM];
   
   multiplier = 0;
   kind       = is_unknown;

   // deal with next/previous
   for( word in components)
   {
      len = [word length];
      if( ! len)
         continue;
      
      //
      // the earlier / later has to come first, because
      // I don't know where to apply it otherwise
      //
      switch( kind)
      {
      case is_unknown :
         if( word == NSEarlierTimeDesignationsKey)
         {
            kind = is_relative;
            multiplier = -1;
            continue;
         }
         
         if( word == NSLaterTimeDesignationsKey)
         {
            kind = is_relative;
            multiplier = +1;
            continue;
         }
         break;
         
      case is_relative :
         if( word == NSYearString)
         {
            relative.year_offset = 1 * multiplier;
            multiplier = 0; // consumed
            continue;
         }
         if( word == NSMonthString)
         {
            relative.month_offset = 1 * multiplier;
            multiplier = 0; // consumed
            continue;
         }

         if( word == NSWeekString)
         {
            relative.week_offset = 1 * multiplier;
            multiplier           = 0; // consumed
            continue;
         }

         i = hour_offset( word);
         if( i >= 0)
         {
            relative.hour_offset = (i + 1) * multiplier;
            multiplier           = 0; // consumed
            continue;
         }

         // next "may", is probably always may in next year ?
         i = index_of_month( word);
         if( i >= 0)
         {
            relative.named_month_offset  = (i + 1) * multiplier;
            multiplier = 0;
            continue;
         }

         // previous "tuesday", is probably at least 7 days agok ?
         i = index_of_weekday( word);
         if( i >= 0)
         {
            relative.named_weekday_offset = (i + 1) * multiplier;
            multiplier = 0;
            continue;
         }

         // hour designations (next noon)
         if( [word __isNSNumber])
         {
            relative.named_hour_offset = ([(NSNumber *) word integerValue] + 1) * multiplier;
            multiplier = 0; // consumed
            continue;
         }
      }

      // do noon..
      i = index_of_month( word);
      if( i >= 0)
      {
         tm.month = i + 1;
         s_ordering = strchr( buf, 'M') + 1;
         kind = is_absolute;
         continue;
      }

      // not really absolute though
      i = hour_offset( word);
      if( i >= 0)
      {
         tm.hour = i;
         s_ordering = strchr( buf, 'D') + 1;
         continue;
      }
      
      // hour designations, just take them as they are
      if( [word __isNSNumber])
      {
         tm.hour = [(NSNumber *) word integerValue];
         s_ordering = strchr( buf, 'H') + 1;
         kind = is_absolute;
         continue;
      }

      if( [word rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].length == len)
      {
         value = [word integerValue];
         switch( *s_ordering)
         {
         case 'Y' :
            tm.year   = value;
            break;
         case 'M' :
            tm.month  = value;
            break;
         case 'D' :
            tm.day    = value;
            break;
         case 'H' :
            tm.hour   = value;
            break;
         case 'm' :
            tm.minute = value;
            break;
         case 's' :
            tm.second = value;
            break;
         }
         
         // done ?
         if( ! *++s_ordering)
            break;
         kind = is_absolute;
      }
      
      if( word == NSPMString)
      {
         if( tm.hour && tm.hour <= 12)
            tm.hour += 12;
         kind = is_absolute;
         break; // assume done
      }
   }

   // now lets see what we have...
   // we can combine relative date with time
   // otherwise, if we have

   date = now;
   if( kind == is_absolute)
      date = [[[NSCalendarDate alloc] _initWithMiniTM:tm] autorelease];
   
   date = [date _calendarDateWithDateOffsets:&relative];
   return( date);
}


+ (instancetype) dateWithNaturalLanguageString:(NSString *) s
                                        locale:(id) locale
{
   return( [self _dateWithNaturalLanguageString:s
                                         locale:locale
                                  referenceDate:nil]);
}
@end



// backwards comp.
@implementation NSDate( NSUserDefaults)

+ (instancetype) dateWithNaturalLanguageString:(NSString *) string
                                        locale:(id) locale
{
   return( [[NSCalendarDate dateWithNaturalLanguageString:string
                                                   locale:locale] date]);
}


+ (instancetype) dateWithNaturalLanguageString:(NSString *) string;
{
   return( [[NSCalendarDate dateWithNaturalLanguageString:string] date]);
}

@end


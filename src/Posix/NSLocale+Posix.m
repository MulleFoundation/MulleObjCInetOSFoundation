/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSLocale.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSLocale+Posix.h"

// other files in this library
#import "NSFileManager.h"
#import "NSString+Posix.h"

// std-c and dependencies
#include <locale.h>
#include <xlocale.h>
#include <langinfo.h>


@interface NSString ( CString)

+ (instancetype) stringWithCString:(char *) s;
- (char *) cString;

@end


typedef struct
{
   unsigned short    type;
   unsigned short    code;
} local_key_info;


static inline local_key_info   make_local_key_info( NSUInteger type, NSUInteger code) 
{
   NSCParameterAssert( type == (NSUInteger) -1 || type <= USHRT_MAX);
   NSCParameterAssert( code <= USHRT_MAX);
   
   local_key_info    info;
   
   info.type  = (unsigned short) type;
   info.code  = (unsigned short) code;
   return( info);
}


enum
{
   ERROR_INFO = -1,
   IDENTIFIER_INFO,
   LANG_INFO,
   CONV_INFO,
   QUERY_INFO
};   


enum
{
   QUERY_COLLATION,
   QUERY_IDENTIFIER,
   QUERY_LANGUAGE,
   QUERY_SCRIPT,
   QUERY_VARIANT

};
   
enum
{
   CONV_DECIMAL_POINT,
   CONV_THOUSANDS_SEPERATOR,
   CONV_GROUPING,
   CONV_INT_CURRENCY_SYMBOL,
   CONV_CURRENCY_SYMBOL,
   CONV_MONEY_DECIMAL_POINT,
   CONV_MONEY_THOUSANDS_SEPERATOR,
   CONV_MONEY_GROUPING,
   CONV_POSITIVE_SIGN,
   CONV_NEGATIVE_SIGN,
   CONV_INT_FRACTIONAL_DIGITS,
   CONV_FRACTIONAL_DIGITS,
   CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_POSITIVE_SIGN_POSITION,
   CONV_NEGATIVE_SIGN_POSITION,
   CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_INT_POSITIVE_SIGN_POSITION,
   CONV_INT_NEGATIVE_SIGN_POSITION
};   

#define match( key, identifier, type, code)        \
   if( [key isEqualToString:identifier ])          \
   {                                               \
      return( make_local_key_info( type, code));   \
   } 


static local_key_info   map_string_key_to_local_key( NSString *key)
{
   match( key, NSLocaleAlternateQuotationBeginDelimiterKey, -1, 0); 
   match( key, NSLocaleAlternateQuotationEndDelimiterKey, -1, 0); 
   match( key, NSLocaleCalendar, -1, 0); 
   match( key, NSLocaleCollationIdentifier, QUERY_INFO, QUERY_COLLATION); 
   match( key, NSLocaleCollatorIdentifier, -1, 0); 
   match( key, NSLocaleCountryCode, -1, 0); 
   match( key, NSLocaleCurrencyCode, -1, 0); 
   match( key, NSLocaleCurrencySymbol, CONV_INFO, CONV_CURRENCY_SYMBOL); 
   match( key, NSLocaleDecimalSeparator, CONV_INFO, CONV_DECIMAL_POINT); 
   match( key, NSLocaleExemplarCharacterSet, -1, 0); 
   match( key, NSLocaleGroupingSeparator, CONV_INFO, CONV_GROUPING); 
   match( key, NSLocaleIdentifier, IDENTIFIER_INFO, 0); 
   match( key, NSLocaleLanguageCode, QUERY_INFO, QUERY_LANGUAGE); 
   match( key, NSLocaleMeasurementSystem, -1, 0); 
   match( key, NSLocaleQuotationBeginDelimiterKey, -1, 0); 
   match( key, NSLocaleQuotationEndDelimiterKey, -1, 0); 
   match( key, NSLocaleScriptCode, -1, 0); 
   match( key, NSLocaleUsesMetricSystem, -1, 0); 
   match( key, NSLocaleVariantCode, QUERY_INFO, QUERY_VARIANT); 
   
   return( make_local_key_info( ERROR_INFO, 0));
}


static id    locale_conv_l_value( locale_t locale, int code)
{
   struct lconv   *conv;
   char           *s;
   int            nr;
   BOOL           flag;
   
   conv = localeconv_l( locale);
   if( ! conv)
      return( NULL);
      
   nr   = -1;      
   s    = NULL;
   flag = NO;
   
   switch( code)
   {
   default                             : return( nil);
   case CONV_DECIMAL_POINT             : s = conv->decimal_point; break;
   case CONV_THOUSANDS_SEPERATOR       : s = conv->thousands_sep; break; 
   case CONV_GROUPING                  : s = conv->grouping; break; 
   case CONV_INT_CURRENCY_SYMBOL       : s = conv->int_curr_symbol; break;
   
   case CONV_CURRENCY_SYMBOL           : s = conv->currency_symbol; break;
   case CONV_MONEY_DECIMAL_POINT       : s = conv->mon_decimal_point; break;
   case CONV_MONEY_THOUSANDS_SEPERATOR : s = conv->mon_thousands_sep; break; 
   case CONV_MONEY_GROUPING            : s = conv->mon_grouping; break; 

   case CONV_POSITIVE_SIGN             : s = conv->positive_sign; break; 
   case CONV_NEGATIVE_SIGN             : s = conv->negative_sign; break; 
   case CONV_INT_FRACTIONAL_DIGITS     : nr = conv->int_frac_digits; break;
   case CONV_FRACTIONAL_DIGITS         : nr = conv->frac_digits; break;

   case CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES           : flag = conv->p_cs_precedes; break;
   case CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE : flag = conv->p_sep_by_space; break;
   case CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES           : flag = conv->n_cs_precedes; break;
   case CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE : flag = conv->n_sep_by_space; break;

   case CONV_POSITIVE_SIGN_POSITION                      : nr   = conv->p_sign_posn; break;
   case CONV_NEGATIVE_SIGN_POSITION                      : nr   = conv->n_sign_posn; break;
   case CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES : flag = conv->int_p_cs_precedes; break; 
   case CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES : flag = conv->int_n_cs_precedes; break; 

   case CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE : flag = conv->int_p_sep_by_space; break; 
   case CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE : flag = conv->int_n_sep_by_space; break;
   case CONV_INT_POSITIVE_SIGN_POSITION                            : flag = conv->int_p_sign_posn; break;
   case CONV_INT_NEGATIVE_SIGN_POSITION                            : flag = conv->int_n_sign_posn; break;
   }
   
   if( s)
      return( [NSString stringWithCString:s]);

   if( nr != -1)
      return( [NSNumber numberWithInt:nr]);

   return( [NSNumber numberWithBool:flag]);
}


static NSString   *queryLocaleName( int mask, locale_t base)
{
   char   *c_name;
   
   c_name = (char *) querylocale( mask, base);

   return( c_name ? [NSString stringWithCString:c_name] : nil);
}



static id   query_info( int code, locale_t locale)
{
   NSString   *s;
   NSArray    *components;
   int        offset;
   
   offset = 0;
   switch( code)
   {
   default               : return( nil);
   case QUERY_COLLATION  : return( queryLocaleName( LC_COLLATE_MASK, locale));
   case QUERY_IDENTIFIER : return( queryLocaleName( LC_ALL_MASK, locale));
   case QUERY_SCRIPT     : return( nil);
   case QUERY_VARIANT    : ++offset;
   case QUERY_LANGUAGE   : s = queryLocaleName( LC_CTYPE_MASK, locale); break;
   }
   
   components = [s componentsSeparatedByString:@"."];
   if( offset < (int) [components count])
      return( [components objectAtIndex:offset]);
   return( nil);
}


@implementation NSLocale ( Posix)

static id   newLocaleByQuery( Class self, locale_t base)
{
   NSString  *name;

   name = queryLocaleName( LC_ALL_MASK, base);
   if( ! name)
   {
      [self release];
      return( nil);
   }

   return( [[[self alloc] initWithLocaleIdentifier:name] autorelease]);
}


+ (id) systemLocale
{
   return( newLocaleByQuery( self, LC_GLOBAL_LOCALE));
}


+ (id) currentLocale
{
   return( newLocaleByQuery( self, NULL));
}



+ (NSString *) systemLocalePath
{
   return( @"/usr/share/locale");
}


+ (NSArray *) availableLocaleIdentifiers
{
   return( [[NSFileManager defaultManager] directoryContentsAtPath:[self systemLocalePath]]);
}


/*
Try to load a dictionary named:

de_DE.plist
{
    NSAMPMDesignation = ("vorm.", "nachm.");
    NSDateFormatString = "%A, %e. %B %Y";
    NSDateTimeOrdering = DMYH;
    NSEarlierTimeDesignations = ("fr\U00fcher", vorher, letzten );
    NSHourNameDesignations = (
        (0, mitternachts, Mitternacht),
        (8, morgens, Morgen),
        (12, mittags, Mittag),
        (15, nachmittags, Nachmittag),
        (18, abends, Abend)
    );
    NSLaterTimeDesignations = ("n\U00e4chsten");
    NSMonthNameArray = (
        Januar,
        Februar,
        "M\U00e4rz",
        April,
        Mai,
        Juni,
        Juli,
        August,
        September,
        Oktober,
        November,
        Dezember
    );
    NSNextDayDesignations = (morgen);
    NSNextNextDayDesignations = ( "\U00fcbermorgen");
    NSPriorDayDesignations = ( gestern);
    NSShortDateFormatString = "%d.%m.%y";
    NSShortMonthNameArray = (Jan, Feb, Mrz, Apr, Mai, Jun, Jul, Aug, Sep, Okt, Nov, Dez);
    NSShortTimeDateFormatString = "%d.%m.%y %H:%M";
    NSShortWeekDayNameArray = (So, Mo, Di, Mi, Do, Fr, Sa);
    NSThisDayDesignations = ( heute, jetzt);
    NSTimeDateFormatString = "%A, %e. %B %Y %1H:%M Uhr %Z";
    NSTimeFormatString = "%H:%M:%S";
    NSWeekDayNameArray = (Sonntag, Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag);
    NSYearMonthWeekDesignations = ( Jahr, Monat, Woche);
}
*/

+ (NSString *) auxiliaryLocalePath
{
   return( @"/usr/share/mulle-locale");
}


+ (NSDictionary *) auxiliaryLocaleInfoForIdentifier:(NSString *) identifier
{
   NSString  *path;
   
   path = [[self auxiliaryLocalePath] stringByAppendingPathComponent:identifier];
   path = [path stringByAppendingPathExtension:@"plist"];
   return( [NSDictionary dictionaryWithContentsOfFile:path]);
}


- (id) initWithLocaleIdentifier:(NSString *) name
{
   locale_t       xlocale;
   NSDictionary   *auxInfo;
   
   xlocale = newlocale( LC_ALL_MASK, [name cString], NULL);

   if( ! xlocale || ! name)
   {
      [self release];
      return( nil);
   }
   
   _xlocale    = xlocale;
   _identifier = [name copy];
   _keyValues  = [NSMutableDictionary new];
   
   auxInfo = [isa auxiliaryLocaleInfoForIdentifier:name];
   [_keyValues addEntriesFromDictionary:auxInfo];
   
   return( self);
}


- (void) dealloc
{
   [_identifier release];
   [_keyValues release];
   if( _xlocale)
      freelocale( _xlocale);

   [super dealloc];
}


- (NSString *) localeIdentifier
{
   return( _identifier);
}
   
   

- (id) _localeInfoForKey:(id) key
{
   local_key_info   info;
   char             *s;
   
   s    = NULL;
   info = map_string_key_to_local_key( key);

   switch( info.type)
   {
   case IDENTIFIER_INFO : 
      return( _identifier);
   
   case QUERY_INFO : 
      return( query_info( info.code, _xlocale));
      
   case LANG_INFO  : 
      s = nl_langinfo_l( info.code, _xlocale); 
      return( s ? [NSString stringWithCString:s] : nil);

   case CONV_INFO : 
      return( locale_conv_l_value( _xlocale, info.code));
   }
   return( nil);
}


- (id) objectForKey:(id) key
{
   id               value;
   
   value = [_keyValues objectForKey:key];
   if( value)
   {
      if( value == [NSNull null])
         value = nil;
      return( value);
   }
   
   value = [self _localeInfoForKey:key];
   [_keyValues setObject:value ? value : [NSNull null]
                  forKey:key];
   return( value);
}


- (locale_t) xlocale
{
   return( _xlocale);
}

@end


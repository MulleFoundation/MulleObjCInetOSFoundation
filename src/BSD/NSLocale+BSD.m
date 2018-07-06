//
//  NSLocale+BSD.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import-private.h"

// other files in this library
#import <MulleObjCPosixFoundation/private/NSLocale+Posix-Private.h>

// std-c and dependencies
#include <langinfo.h>


static id    mulle_localeconv_value( locale_t locale, int code)
{
   struct lconv   *conv;

   conv = localeconv_l( locale);
   if( ! conv)
      return( NULL);

   return( mulle_locale_lconv_value( conv, code));
}


static NSString   *queryLocaleName( int mask, locale_t base)
{
   char   *c_name;

   c_name = (char *) querylocale( mask, base);

   return( c_name ? [NSString stringWithCString:c_name] : nil);
}


@implementation NSLocale( BSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


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


+ (NSString *) systemLocalePath
{
   return( @"/usr/share/locale");
}


+ (instancetype) systemLocale
{
   return( newLocaleByQuery( self, LC_GLOBAL_LOCALE));
}


+ (instancetype) currentLocale
{
   return( newLocaleByQuery( self, NULL));
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


- (id) _localeInfoForKey:(id) key
{
   struct mulle_locale_key_info   info;
   char                           *s;

   s    = NULL;
   info = mulle_locale_map_string_key_to_local_key( key);

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
      return( mulle_localeconv_value( _xlocale, info.code));
   }
   return( nil);
}

@end

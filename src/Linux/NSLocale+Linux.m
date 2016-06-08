//
//  NSLocale+Linux.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <locale.h>
#include <xlocale.h>


@implementation NSLocale (Linux)

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


+ (id) systemLocale
{
   return( newLocaleByQuery( self, LC_GLOBAL_LOCALE));
}


+ (id) currentLocale
{
   return( newLocaleByQuery( self, NULL));
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
   
   case LANG_INFO  : 
      s = nl_langinfo_l( info.code, _xlocale); 
      return( s ? [NSString stringWithCString:s] : nil);
   }
   return( nil);
}

@end

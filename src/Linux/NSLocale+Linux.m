//
//  NSLocale+Linux.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <NSLocale+PosixPrivate.h>

// std-c and dependencies
#include <locale.h>
#include <xlocale.h>
#include <langinfo.h>


@implementation NSLocale (Linux)

+ (SEL *) categoryDependencies
{
   static SEL   dependencies[] =
   {
      @selector( Posix),
      0
   };
   
   return( dependencies);
}


+ (NSString *) systemLocalePath
{
   return( @"/usr/share/locale");
}


+ (id) systemLocale
{
   // bullshit
   return( [[[NSLocale alloc] initWithLocaleIdentifier:@"C"] autorelease]);
}


+ (id) currentLocale
{
   // bullshit
   return( [[[NSLocale alloc] initWithLocaleIdentifier:@"C"] autorelease]);
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

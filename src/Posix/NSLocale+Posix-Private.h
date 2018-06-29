//
//  NSLocale+Posix-Private.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#include <locale.h>


struct mulle_locale_key_info
{
   unsigned short   type;
   unsigned short   code;
};


static inline struct mulle_locale_key_info   make_mulle_locale_key_info( NSUInteger type, NSUInteger code)
{
   NSCParameterAssert( type == (NSUInteger) -1 || type <= USHRT_MAX);
   NSCParameterAssert( code <= USHRT_MAX);

   struct mulle_locale_key_info    info;

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


struct mulle_locale_key_info   mulle_locale_map_string_key_to_local_key( NSString *key);

id    mulle_locale_lconv_value( struct lconv *conv, int code);


@interface NSLocale( Posix_Private)

- (locale_t) xlocale;

@end

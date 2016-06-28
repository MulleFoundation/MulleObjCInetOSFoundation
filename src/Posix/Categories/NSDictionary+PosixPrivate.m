/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSDictionary+Posix_Private.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700
 
#import "NSDictionary+PosixPrivate.h"

// other files in this library
#import "NSString+CString.h"

// std-c and dependencies


@implementation NSDictionary( PosixPrivate)

+ (NSDictionary *) _newWithEnvironment:(char **) env
{
   NSMutableDictionary   *dictionary;
   NSString              *key;
   NSString              *value;
   char                  **p;
   char                  *s;
   char                  *c_key;
   char                  *c_value;
   size_t                c_key_len;
   size_t                c_value_len;
   
   dictionary = [NSMutableDictionary new];
   
   p = env;
   while( *p)
   {
      s       = *p++;
      c_key   = s;
      c_value = strchr( s, '=');

      if( c_value)
      {
         c_key_len = c_value - c_key;
         if( ! *++c_value)
            c_value = NULL;
         else
            c_value_len = strlen( c_value);
      }
      else
         c_key_len = strlen( c_key);
         
      if( ! c_value)
      {
         c_value = "YES";
         c_value_len = 3;
      }
      
      key = [[NSString alloc] initWithCString:c_key
                                       length:c_key_len];
      value = [[NSString alloc] initWithCString:c_value
                                         length:c_value_len];
      [dictionary setObject:value
                     forKey:key];
      [key release];
      [value release];
   }
   
   return( dictionary);
}
@end

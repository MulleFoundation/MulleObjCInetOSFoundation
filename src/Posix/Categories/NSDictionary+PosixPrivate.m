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
   char                  *ctxt;
   
   dictionary = [NSMutableDictionary new];
   
   p = env;
   while( *p)
   {
      s       = *p++;
      c_key   = strtok_r( s, "=", &ctxt);
      c_value = strtok_r( NULL, "=", &ctxt);
      
      key = [[NSString alloc] initWithCString:c_key
                                       length:strlen( c_key)];
      if( ! c_value)
         c_value = "YES";
      value = [[NSString alloc] initWithCString:c_value
                                         length:strlen( c_value)];
      [dictionary setObject:value
                     forKey:key];
      [key release];
      [value release];
   }
   
   return( dictionary);
}


+ (NSDictionary *) _newWithEnvironmentNoCopy:(char **) env
{
   NSDictionary   *dictionary;
   char           **p;
   char           *s;

   dictionary = [self _newWithEnvironment:env];
   
   p = env;
   while( *p)
   {
      s = *p++;
      free( s);
   }
   
   free( env);
   
   return( dictionary);
}

@end

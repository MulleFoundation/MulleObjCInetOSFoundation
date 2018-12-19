//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"


#include <stdio.h>



int   main( int argc, const char * argv[])
{
   NSDictionary    *environment;
   NSEnumerator    *rover;
   NSString        *cString;
   NSString        *key;
   char            *env_s;
   char            *key_s;
   id              value;
   unsigned int    i;

   environment = [[NSProcessInfo processInfo] environment];
   if( ! [environment count])
   {
      printf( "fail\n");
      return( -1);
   }

   i = 0;
   rover = [environment keyEnumerator];
   while( key = [rover nextObject])
   {
      key_s   = [key cString];
      env_s   = getenv( key_s);
      cString = [NSString stringWithCString:env_s];
      value   = [environment objectForKey:key];
      if( ! value)
         printf( "#%u: environment key %s value missing\n", i, key_s);

      if( ! [value isEqualToString:cString])
         printf( "#%u: environment key %s value \'%s\' != \"%s\"\n",
                        i,
                        key_s, env_s ? env_s : "",
                        [value cString] ? [value cString] : "");
      ++i;
   }

   return( 0);
}

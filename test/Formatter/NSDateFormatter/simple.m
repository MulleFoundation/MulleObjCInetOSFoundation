//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#ifdef __MULLE_OBJC__
# import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif



int   main( int argc, const char * argv[])
{
   NSDateFormatter   *formatter;
   NSDate            *date;

#ifdef __MULLE_OBJC__
   if( mulle_objc_check_universe() != mulle_objc_universe_is_ok)
      return( 1);
#endif

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%dT%H:%M:%SZ"
                                       allowNaturalLanguage:NO] autorelease];

   date = [formatter dateFromString:@"2013-02-24T20:09:15Z"];
   printf( "%s\n", [[formatter stringFromDate:date] UTF8String]);

   return( 0);
}

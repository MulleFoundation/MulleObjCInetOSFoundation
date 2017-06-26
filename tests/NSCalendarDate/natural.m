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
# pragma message( "Apple Foundation")
#endif


static char  *inputs[] =
{
   "today",
   "Yesterday",
   "TOMORROW",
   "next friday",
   "last may",
   "next april",
   0
};


int   main( int argc, const char * argv[])
{
   NSCalendarDate    *date;
   NSCalendarDate    *today;
   NSDateFormatter   *formatter;
   NSString          *s;
   char              **p;

#ifdef __MULLE_OBJC__
   if( mulle_objc_check_universe() != mulle_objc_universe_is_ok)
      return( 1);
#endif
   // noon 2000
   today = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:12 * 60 * 60] autorelease];

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%y-%m-%dT%H:%M:%SZ%z"
                                       allowNaturalLanguage:NO] autorelease];

   assert( formatter);

   for( p = inputs; *p; p++)
   {
      s    = [NSString stringWithUTF8String:*p];
#ifdef __MULLE_OBJC__
      date = [NSCalendarDate  _calendarDateWithNaturalLanguageString:s
                                                              locale:nil
                                               referenceCalendarDate:today];
#else
      date = [NSCalendarDate dateWithNaturalLanguageString:s
                                                    locale:nil];
#endif
      printf( "%s -> ", *p);
      if( date)
      {
         printf( "%.3f -> ", [date timeIntervalSinceReferenceDate]);
         s = [formatter stringFromDate:date];
         if( ! s)
            printf( "*nil*");
         else
            printf( "\"%s\"", [s UTF8String]);
      }
      else
         printf( "*nil*");

      printf( "\n");
   }

   return( 0);
}

/*

OS X is kinda broken IMO so let's not use it as reference

today -> 516492000.000 -> "17-05-15T00:00:00Z+0200"
Yesterday -> 516448800.000 -> "17-05-14T12:00:00Z+0200"
TOMORROW -> 516621600.000 -> "17-05-16T12:00:00Z+0200"
next friday -> 516880800.000 -> "17-05-19T12:00:00Z+0200" ???
last may -> 516535200.000 -> "17-05-15T12:00:00Z+0200"    ???
next april -> 513943200.000 -> "17-04-15T12:00:00Z+0200"  ???

*/

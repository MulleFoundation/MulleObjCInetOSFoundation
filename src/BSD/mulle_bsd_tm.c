//
//  mulle_bsd_tm.c
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#include "mulle_bsd_tm.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#include "mulle_posix_tm.h"

// std-c and dependencies
#include <limits.h>
#include <locale.h>
#include <time.h>
#include <xlocale.h>



void   mulle_bsd_tm_invalidate( struct tm *tm)
{
   mulle_posix_tm_invalidate( tm);

   tm->tm_gmtoff = LONG_MIN; // LONG_MIN here
   tm->tm_zone   = (void *) &tm;  // surely NOT a zone address
}


int   mulle_bsd_tm_is_invalid( struct tm *tm)
{
   if( mulle_posix_tm_is_invalid( tm))
      return( 1);
   if( tm->tm_gmtoff == LONG_MIN && tm->tm_zone == (void *) tm)
      return( 1);
   return( 0);
}


unsigned int   mulle_bsd_tm_augment( struct tm *tm, struct tm *now, enum mulle_bsd_tm_status *has_tz)
{
   unsigned int  n;

   n = mulle_posix_tm_augment( tm, now);

   *has_tz = mulle_bsd_tm_no_tz;

   if( tm->tm_gmtoff == LONG_MIN && tm->tm_zone == (char *) &tm)
   {
      ++n;
      tm->tm_gmtoff = now->tm_gmtoff;
      *has_tz       = mulle_bsd_tm_with_tz;
   }

   return( n);
}



enum mulle_bsd_tm_status   mulle_bsd_tm_from_string_with_format( struct tm *tm,
                                                                 char **c_str_p,
                                                                 char *c_format,
                                                                 locale_t locale,
                                                                 int is_lenient)
{
   char                       *c_str;
   struct tm                  now;
   time_t                     nowtimeval;
   unsigned int               n;
   enum mulle_bsd_tm_status   has_tz;

   // set it all to int min, that way we can deduce how much
   // strptime was able to parse for "leniency"

   mulle_bsd_tm_invalidate( tm);

   c_str     = *c_str_p;
   *c_str_p  = strptime_l( c_str, c_format, tm, locale);

   if( ! *c_str_p && ! is_lenient)
      return( mulle_bsd_tm_error);

   has_tz = mulle_bsd_tm_no_tz;
   if( mulle_bsd_tm_is_invalid( tm))
   {
      // augment formatter with current time (or only when parsing failed ?)
      nowtimeval = time( NULL);
      gmtime_r( &nowtimeval, &now);  // localtime, gmtime ???

      n = mulle_bsd_tm_augment( tm, &now, &has_tz);

      // absolutely no conversion and we failed parsing, strange
      if( ! n && ! *c_str_p)
         return( mulle_bsd_tm_error);
   }

   return( has_tz);
}


void  mulle_bsd_tm_with_timeintervalsince1970( struct tm *tm,
                                               double timeInterval,
                                               unsigned int secondsFromGMT)
{
   mulle_posix_tm_with_timeintervalsince1970( tm, timeInterval, secondsFromGMT);
   tm->tm_gmtoff = secondsFromGMT;
}



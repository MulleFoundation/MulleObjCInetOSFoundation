//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import-private.h"

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/private/NSDate+OSBase-Private.h>
#import <MulleObjCPosixFoundation/private/NSLocale+Posix-Private.h>
#import <MulleObjCPosixFoundation/private/mulle_posix_tm-private.h>

// std-c and dependencies
#import <time.h>
#import <xlocale.h>


#pragma clang diagnostic ignored "-Wparentheses"

@implementation NSDateFormatter( Darwin)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}

//
// as strange as it may sound, on DARWIN strftime is broken (by design)
// with respect to %z and %Z
// https://opensource.apple.com/source/Libc/Libc-1244.30.3/stdtime/FreeBSD/strftime.c.auto.html
//
// So we preparse the format and output the correct timezone into a copy
// of the format string :(
//
//
static char  *percent_z_find( char *s)
{
   int   c;
   int   d;

   // search for %z or %Z
   c = 0;
   for(;;)
   {
      d = c;
      c = *s++;
      if( ! c)
         break;

      if( d != '%')
         continue;

      if( c == 'z' || c == 'Z')
         return( s - 2);

      c = 0;  // look for % again
   }
   return( NULL);
}


static unsigned int   percent_count( char *s)
{
   int           c;
   unsigned int  n;

   n = 0;
   while( c = *s++)
      if( c == '%')
         ++n;

   return( n);
}


static void   percent_escape( char *dst, char *src)
{
   int   c;

   do
   {
      c = *src++;
      if( c == '%')
         *dst++ = c;
      *dst++ = c;
   }
   while( c);
}


static void   percent_z_replace( char *dst,
                                 char *src,
                                 struct tm *tm,
                                 size_t tzname_len)
{
   int   c;
   int   d;
   int   secs;
   int   mins;
   int   sign;

   // search for %z or %Z, and replace with tm info
   c = 0;
   for(;;)
   {
      d = c;
      c = *src++;
      if( ! c)
      {
         *dst++ = c;
         return;
      }

      if( d != '%')
      {
         if( c != '%')
            *dst++ = c;
         continue;
      }

      switch( c)
      {
      case 'z' :
         secs = tm->tm_gmtoff;
         sign = '+';
         if( secs < 0)
         {
            sign = '-';
            secs = -secs;
         }

         // copied from bsd, i have no idea what this does
         mins = secs / 60;
         mins = (mins / 60) * 100 + (mins % 60);

         // own code
         *dst++ = sign;
         mins %= 10000;
         *dst++ = '0' + (mins / 1000);
         mins %= 1000;
         *dst++ = '0' + (mins / 100);
         mins %= 100;
         *dst++ = '0' + (mins / 10);
         mins %= 10;
         *dst++ = '0' + mins;
         break;

      case 'Z' :
         memcpy( dst, tm->tm_zone, tzname_len);
         dst += tzname_len;
         break;

      default :
         *dst++ = '%';
         *dst++ = c;
      }
      c = 0;
   }
}



- (size_t) _printTM:(struct tm *) tm
             buffer:(char *) buf
             length:(size_t) len
      cStringFormat:(char *) c_format
             locale:(NSLocale *) locale
{
   locale_t    xlocale;
   char        *start;
   size_t      len;
   struct tm   tmp;
   size_t      tzname_len;
   size_t      needed_len;

   xlocale = [locale xlocale];

   start = percent_z_find( c_format);
   if( ! start)
   {
      if( xlocale)
         len = strftime_l( buf, len, c_format, tm, xlocale);
      else
         len = strftime( buf, len, c_format, tm);
      return( len);
   }

   //
   // calculate what we need to convert
   //
   tzname_len = 0;
   needed_len = strlen( c_format);

   do
   {
      if( start[ 1] == 'Z')
      {
         if( ! tzname_len)
         {
            if( ! tm->tm_zone)
               MulleObjCThrowInvalidArgumentException( @"Timezone name is needed");
            if( strchr( tm->tm_zone, '%'))
               MulleObjCThrowInvalidArgumentException( @"Timezone with %% is not possible");
            tzname_len = strlen( tm->tm_zone);
         }
         needed_len += tzname_len - 2;  // - %Z
      }
      else
         needed_len += 5 - 2; // (sign + 0000) - (%z)

      start = percent_z_find( start + 2);
   }
   while( start);

   if( needed_len > 1024)
      MulleObjCThrowInvalidArgumentException( @"Format string too long");

   //
   // now convert the c_format into a temporary buffer
   // with expanded %z and %Z values. needed_len fits tight.
   //
   {
      char  tmp_format[ needed_len + 1 + 1];

#ifndef NDEBUG
      tmp_format[ needed_len]     = -38;
      tmp_format[ needed_len + 1] = -38;
#endif
      percent_z_replace( tmp_format, c_format, tm, tzname_len);

      assert( tmp_format[ needed_len] == 0);
      assert( tmp_format[ needed_len + 1] == -38);

      if( xlocale)
         len = strftime_l( buf, len, tmp_format, tm, xlocale);
      else
         len = strftime( buf, len, tmp_format, tm);
      return( len);
   }
}

@end

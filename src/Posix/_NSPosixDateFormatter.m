//
//  MulleObjCDateFormatter.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

#import "_NSPosixDateFormatter.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/private/NSDate+OSBase-Private.h>
#import "MulleObjCPOSIXError.h"
#import "NSLocale+Posix.h"
#import "NSLocale+Posix-Private.h"

// other libraries of MulleObjCPosixFoundation
#include "mulle_posix_tm-private.h"
#import "NSCalendarDate+Posix-Private.h"

// std-c and dependencies
#include <time.h>


@interface NSObject (Private)

- (BOOL) __isNSCalendarDate;

@end


@implementation _NSPosixDateFormatter


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (void) load
{
   [NSDateFormatter mulleSetClass:self
             forFormatterBehavior:NSDateFormatterBehavior10_0];
}


- (NSDateFormatterBehavior) formatterBehavior
{
   return( NSDateFormatterBehavior10_0);
}


- (void) setDateFormat:(NSString *) format
{
   size_t   length;

   if( _cformat)
      MulleObjCObjectDeallocateMemory( self, _cformat);

   length   = [format cStringLength];
   _cformat = MulleObjCObjectAllocateNonZeroedMemory( self, length + 1);
   [format getCString:_cformat
            maxLength:length+1];

   // This an initial heuristic, later formatting will increase this
   // if needed
   length *= 4;
   if( length < 256)
      length = 256;

   _buflen = length;
}


#pragma mark -
#pragma mark conversions


- (id) _dateWithCStringFormat:(char *) c_format
               cStringPointer:(char **) c_str_p
{
   int              rval;
   NSCalendarDate   *calendarDate;
   NSDate           *date;
   struct tm        tm;

   rval = mulle_posix_tm_from_string_with_format( &tm,
                                                 c_str_p,
                                                 c_format,
                                                 [[self locale] xlocale],
                                                 [self isLenient]);
   if( rval < 0)
      return( nil);

   calendarDate = [[NSCalendarDate alloc] _initWithTM:&tm
                                             timeZone:[self timeZone]];
   if( [self generatesCalendarDates])
      return( [calendarDate autorelease]);

   date = [NSDate dateWithTimeIntervalSince1970:[calendarDate timeIntervalSince1970]];
   [calendarDate release];

   return( date);
}


// TODO: use a mulle_buffer ?
- (size_t) _printDate:(NSDate *) date
               buffer:(char *) buf
               length:(size_t) len
        cStringFormat:(char *) c_format
               locale:(NSLocale *) locale
             timeZone:(NSTimeZone *) timeZone
{
   struct tm   tm;

   mulle_posix_tm_with_timeintervalsince1970( &tm,
                                             [date timeIntervalSince1970],
                                             (unsigned int) [timeZone secondsFromGMTForDate:date]);
   return( [self _printTM:&tm
                   buffer:buf
                   length:len
            cStringFormat:c_format
                   locale:locale]);
}


//
// a NSDate is a GMT date, it should be rendered as GMT alas
// the user may specify a timeZone...
//
- (NSString *) stringFromDate:(NSDate *) date
{
   char         *buf;
   NSLocale     *locale;
   NSString     *s;
   NSTimeZone   *timeZone;
   size_t       len;

   timeZone = [self timeZone];
   if( ! timeZone && [date __isNSCalendarDate])
      timeZone = [(NSCalendarDate *) date timeZone];

   locale = [self locale];

   // NSLog( @"Using tz %@", [timeZone abbreviation]);
   // NSLog( @"Using locale %@", [locale localeIdentifier]);

   //
   // TODO: use alloca or somesuch instead of buf ?
   //
   buf = NULL;
   for(;;)
   {
      buf = mulle_allocator_realloc( NULL, buf, _buflen);
      len = [self _printDate:date
                      buffer:buf
                      length:_buflen
               cStringFormat:_cformat
                      locale:locale
                    timeZone:timeZone];
      if( len)
      {
          s = [NSString stringWithCString:buf
                                   length:len + 1];
          mulle_allocator_free( NULL, buf);
          return( s);
      }
      _buflen *= 2;  // weak ...
   }
}


- (NSDate *) dateFromString:(NSString *) s
{
   char     *c_str;
   NSDate   *date;

   c_str = [s cString];
   date  = [self _dateWithCStringFormat:_cformat
                         cStringPointer:&c_str];
   return( date);
}


- (BOOL) getObjectValue:(id *) obj
              forString:(NSString *) string
                  range:(NSRange *) rangep
                  error:(NSError **) error
{
   char     *c_begin;
   char     *c_end;
   NSDate   *date;

   c_begin = [string cString];
   c_end   = c_begin;
   date    = [self _dateWithCStringFormat:_cformat
                           cStringPointer:&c_end];
   if( ! date)
   {
      errno = EINVAL; // whatever
      return( NO);
   }

   *obj = date;
   if( rangep)
      *rangep = NSMakeRange( 0, c_end - c_begin);
   return( YES);
}

@end

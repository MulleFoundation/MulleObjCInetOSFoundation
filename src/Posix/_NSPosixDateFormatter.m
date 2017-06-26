//
//  MulleObjCDateFormatter.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "_NSPosixDateFormatter.h"

// other files in this library
#import "NSDate+OSBasePrivate.h"
#import "MulleObjCPOSIXError.h"
#import "NSLocale+Posix.h"
#import "NSLocale+PosixPrivate.h"
#import "NSLog.h"

// other libraries of MulleObjCPosixFoundation
#include "mulle_posix_tm.h"

// std-c and dependencies
#include <time.h>
#include <xlocale.h>


@interface NSObject (Private)

- (BOOL) __isNSCalendarDate;

@end


@implementation _NSPosixDateFormatter

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( NSConstantString), 0 },
      { 0, 0 }
   };

   return( dependencies);
}


+ (void) load
{
   [NSDateFormatter setClassValue:self
                           forKey:NSDateFormatter1000BehaviourClassKey];
   [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_0];
}


- (NSDateFormatterBehavior) formatterBehavior
{
   return( NSDateFormatterBehavior10_0);
}


- (instancetype) _initWithDateFormat:(NSString *) format
                allowNaturalLanguage:(BOOL) flag
{
   size_t   length;

   self = [super _initWithDateFormat:format
                allowNaturalLanguage:flag];
   if( self)
   {
      length   = [format cStringLength];
      _cformat = MulleObjCObjectAllocateNonZeroedMemory( self, length + 1);
      [format getCString:_cformat
               maxLength:length+1];

      // just a heuristic
      length *= 4;
      if( length < 256)
         length = 256;

      _buflen = length;
   }
   return( self);
}


- (void) dealloc
{
   MulleObjCObjectDeallocateMemory( self, _cformat);
   [super dealloc];
}


#pragma mark -
#pragma mark conversions


- (id) _dateWithCStringFormat:(char *) c_format
               cStringPointer:(char **) c_str_p
{
   NSDate           *date;
   int              rval;
   struct tm        tm;
   NSCalendarDate   *calendarDate;

   rval = mulle_posix_tm_from_string_with_format( &tm,
                                                 c_str_p,
                                                 c_format,
                                                 [[self locale] xlocale],
                                                 [self isLenient]);
   if( rval < 0)
      return( nil);

   calendarDate = [[NSCalendarDate alloc] _initWithTM:&tm
                                             timeZone:[self timeZone]];
   if( [self generateCalendarDates])
      return( [calendarDate autorelease]);

   date = [NSDate dateWithTimeIntervalSince1970:[calendarDate timeIntervalSince1970]];
   [calendarDate release];

   return( date);
}


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
   NSString     *s;
   size_t       len;
   char         *buf;
   NSTimeZone   *timeZone;
   NSLocale     *locale;

   timeZone = [self timeZone];
   if( ! timeZone && [date __isNSCalendarDate])
      timeZone = [(NSCalendarDate *) date timeZone];

   locale = [self locale];

   NSLog( @"Using tz %@", [timeZone abbreviation]);
   NSLog( @"Using locale %@", [locale localeIdentifier]);

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
      MulleObjCPOSIXSetCurrentErrnoError( error);
      return( NO);
   }

   *obj = date;
   if( rangep)
      *rangep = NSMakeRange( 0, c_end - c_begin);
   return( YES);
}

@end

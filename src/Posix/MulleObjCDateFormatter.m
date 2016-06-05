//
//  MulleObjCDateFormatter.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "MulleObjCDateFormatter.h"

// other files in this library
#import "NSCalendarDate.h"
#import "NSDate+PosixPrivate.h"
#import "NSError+Posix.h"
#import "NSLocale+Posix.h"
#import "NSLocale+PosixPrivate.h"
#import "NSString+CString.h"
#import "NSLog.h"

// other libraries of MulleObjCPosixFoundation
#include "mulle_posix_tm.h"

// std-c and dependencies
#include <time.h>
#include <xlocale.h>
#include <alloca.h>


@implementation MulleObjCDateFormatter

+ (void) load
{
   @autoreleasepool
   {
      [NSDateFormatter setClassValue:self
                              forKey:NSDateFormatter1000BehaviourClassKey];
      [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_0];
   }
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




//
// a NSDate is a GMT date, it should be rendered as GMT alas
// the user may specify a timeZone...
//
- (NSString *) stringFromDate:(NSDate *) date
{
   size_t   len;
   char     *buf;
   
   for(;;)
   {
      buf = alloca( _buflen);

      len = [date _getAsCString:buf
                         length:_buflen
                  cStringFormat:_cformat
                         locale:[self locale]
                       timeZone:[self timeZone]];
      if( len)
         return( [NSString stringWithCString:buf
                                      length:len + 1]);
      _buflen *= 2;  // weak ...
   }
}


- (NSDate *) dateFromString:(NSString *) s
{
   char     *c_str;
   NSDate   *date;
   
   c_str = [s cString];
   date  = [_dateClass _dateWithCStringFormat:_cformat
                                       locale:[self locale]
                                     timeZone:[self timeZone]
                                    isLenient:[self isLenient]
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
   date    = [_dateClass _dateWithCStringFormat:_cformat
                                         locale:[self locale]
                                       timeZone:[self timeZone]
                                      isLenient:[self isLenient]
                                 cStringPointer:&c_end];
   if( ! date)
   {
      errno = EINVAL; // whatever
      MulleObjCSetCurrentErrnoError( error);
      return( NO);
   }
   
   *obj = date;
   if( rangep)
      *rangep = NSMakeRange( 0, c_end - c_begin);
   return( YES);
}

@end

//
//  NSDate+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#define _XOPEN_SOURCE 700

#import "import-private.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <time.h>
#include <sys/time.h>


@implementation NSDate (Posix)


NSTimeInterval   MulleDateNow( void)
{
   NSTimeInterval    seconds;
   struct timeval    tv;

   gettimeofday( &tv, NULL);  // is known to be UTC
   seconds = (double) tv.tv_sec  +  (double) tv.tv_usec / 1000000.0;
   return( seconds);
}


+ (instancetype) date
{
   NSTimeInterval    seconds;

   seconds = MulleDateNow();
   return( [[[self alloc] initWithTimeIntervalSinceReferenceDate:seconds] autorelease]);
}


+ (NSTimeInterval) timeIntervalSinceReferenceDate
{
   return( MulleDateNow());
}


// is it ok to be negative ? i guess so

- (struct timeval) _timevalForSelect
{
   NSTimeInterval   now;
   NSTimeInterval   interval;
   struct timeval   value;

   now      = MulleDateNow();
   interval = _interval - now;
   if( interval < 0)
   {
      value.tv_sec  = 0;
      value.tv_usec = 0;
   }
   else
   {
      value.tv_sec  = (long) interval;
      value.tv_usec = (int) ((interval - (NSTimeInterval) value.tv_sec) * 1000000);
   }
   return( value);
}

@end

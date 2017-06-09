//
//  NSDate+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#define _XOPEN_SOURCE 700

#import "MulleObjCOSBaseFoundation.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <time.h>
#include <sys/time.h>


@implementation NSDate (Posix)

+ (instancetype) date
{
   NSTimeInterval   seconds;

   seconds = time( NULL) + NSTimeIntervalSince1970;
   return( [[[self alloc] initWithTimeIntervalSinceReferenceDate:seconds] autorelease]);
}


+ (NSTimeInterval) timeIntervalSinceReferenceDate
{
   return( time( NULL) - NSTimeIntervalSince1970);
}


// is it ok to be negative ? i guess so

- (struct timeval) _timevalForSelect
{
   NSTimeInterval   now;
   NSTimeInterval   interval;
   struct timeval   value;

   now      = time( NULL) - NSTimeIntervalSince1970 ;
   interval = _interval - now;
   if( interval < 0)
   {
      value.tv_sec  = 0;
      value.tv_usec = 0;
   }
   else
   {
      value.tv_sec  = (long) interval;
      value.tv_usec = (int) ((value.tv_sec - interval) * 1000000);
   }
   return( value);
}

@end

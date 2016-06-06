/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+Posix.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700
 
#import "NSString+Posix.h"

// other files in this library
#import "NSData+Posix.h"

// std-c and dependencies


@implementation NSString( Posix)

+ (id) stringWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


- (id) initWithContentsOfFile:(NSString *) path
{
   NSData             *data;
   uint8_t            *bytes;
   NSUInteger         length;
   NSStringEncoding   encoding;
   mulle_utf16_t      c16;
   mulle_utf32_t      c32;
   
   data = [NSData dataWithContentsOfFile:path];
   if( ! data)
   {
      [self release];
      return( nil);
   }
   
   length   = [data length];
   encoding = NSUTF8StringEncoding;

   do
   {
      if( ! length)
         break;
      // if length is odd, it must be 8 bit
      if( length & 0x1)
         break;
      
      bytes = [data bytes];
      c16   = (mulle_utf16_t) ((bytes[ 0] << 8) | bytes[ 1]);
      if( mulle_utf16_get_bom_char() == c16)
      {
         encoding = NSUTF16BigEndianStringEncoding;
         break;
      }
      
      c16   = (mulle_utf16_t) ((bytes[ 1] << 8) | bytes[ 0]);
      if( mulle_utf16_get_bom_char() == c16)
      {
         encoding = NSUTF16LittleEndianStringEncoding;
         break;
      }
      
      if( length < 4)
         break;
      
      c32 = (mulle_utf32_t) ((bytes[ 0] << 24) |
                             (bytes[ 1] << 16) |
                             (bytes[ 2] << 8) |
                              bytes[ 3]);
      if( mulle_utf32_get_bom_char() == c32)
      {
         encoding = NSUTF32BigEndianStringEncoding;
         break;
      }

      c32 = (mulle_utf32_t) ((bytes[ 3] << 24) |
                             (bytes[ 2] << 16) |
                             (bytes[ 1] << 8) |
                              bytes[ 0]);
      if( mulle_utf32_get_bom_char() == c32)
      {
         encoding = NSUTF32LittleEndianStringEncoding;
         break;
      }
   }
   while( 0);
   
   return( [self initWithData:data
                     encoding:encoding]);
   
}

- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSData  *data;
   
   data = [self dataUsingEncoding:NSUTF8StringEncoding];
   return( [data writeToFile:path
                  atomically:flag]);
}

@end

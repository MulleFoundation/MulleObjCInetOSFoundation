//
//  NSString+CString.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 26.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSString+CString.h"

// other files in this library

// std-c and dependencies


@implementation NSString (CString)



+ (instancetype) stringWithCString:(char *) s
{
   return( [[[self alloc] initWithCString:s] autorelease]);
}


+ (instancetype) stringWithCString:(char *) s
                            length:(NSUInteger) len
{
   return( [[[self alloc] initWithCString:s
                                   length:len] autorelease]);
}


- (instancetype) initWithCString:(char *) s
                          length:(NSUInteger) len
{
   return( [self initWithBytes:s
                        length:len
                      encoding:[self _cStringEncoding]]);
}



- (instancetype) initWithCString:(char *) s
{
   return( [self initWithBytes:s
                        length:s ? strlen( s) + 1 : 0
                      encoding:[self _cStringEncoding]]);
}


- (instancetype) initWithCStringNoCopy:(char *) s
                                length:(NSUInteger) length
                          freeWhenDone:(BOOL) flag
{
   return( [self initWithBytesNoCopy:s
                              length:length
                            encoding:[self _cStringEncoding]
                        freeWhenDone:flag]);
}


- (void) getCString:(char *) bytes
{
   if( ! [self getBytes:bytes
              maxLength:[self cStringLength]
             usedLength:NULL
               encoding:[self _cStringEncoding]
                options:0
                  range:NSMakeRange( 0, [self length])
         remainingRange:NULL])
   {
      [NSException raise:@"fail"
                  format:@"fail"];
   }
}


- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
{
   NSUInteger   usedLength;

   NSParameterAssert( maxLength);
   if( ! [self getBytes:bytes
              maxLength:maxLength - 1
             usedLength:&usedLength
               encoding:[self _cStringEncoding]
                options:0
                  range:NSMakeRange( 0, [self length])
         remainingRange:NULL])
   {
      [NSException raise:@"fail"
                  format:@"fail"];
   }
   bytes[ usedLength] = 0;
}


- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
              range:(NSRange) aRange
     remainingRange:(NSRangePointer) leftoverRange
{
   NSUInteger   usedLength;
   NSParameterAssert( maxLength);

   if( ! [self getBytes:bytes
              maxLength:maxLength - 1
             usedLength:&usedLength
               encoding:[self _cStringEncoding]
                options:0
                  range:aRange
         remainingRange:leftoverRange])
   {
      [NSException raise:@"fail"
                  format:@"fail"];
   }
   bytes[ usedLength] = 0;
}

@end

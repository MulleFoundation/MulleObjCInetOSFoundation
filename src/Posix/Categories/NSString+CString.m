//
//  NSString+CString.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 26.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

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
                      encoding:[self cStringEncoding]]);
}



- (instancetype) initWithCString:(char *) s
{
   return( [self initWithBytes:s
                        length:strlen( s)
                      encoding:[self cStringEncoding]]);
}


- (instancetype) initWithCStringNoCopy:(char *) s
                                length:(NSUInteger) length
                          freeWhenDone:(BOOL) flag
{
   return( [self initWithBytesNoCopy:s
                              length:length
                            encoding:[self cStringEncoding]
                        freeWhenDone:flag]);
}


- (void) getCString:(char *) bytes
{
   if( ! [self getBytes:bytes
              maxLength:[self cStringLength]
             usedLength:NULL
               encoding:[self cStringEncoding]
                options:0
                  range:NSMakeRange( 0, [self length])
         remainingRange:NULL])
   {
      [NSException raise:@"fail"
                  format:@"fail"
                  userInfo:nil];
   }
}


- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
{
   if( ! [self getBytes:bytes
              maxLength:maxLength
             usedLength:NULL
               encoding:[self cStringEncoding]
                options:0
                  range:NSMakeRange( 0, [self length])
         remainingRange:NULL])
   {
      [NSException raise:@"fail"
                  format:@"fail"
                  userInfo:nil];
   }
}


- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
              range:(NSRange) aRange
     remainingRange:(NSRangePointer) leftoverRange
{
   if( ! [self getBytes:bytes
              maxLength:maxLength
             usedLength:NULL
               encoding:[self cStringEncoding]
                options:0
                  range:aRange
         remainingRange:leftoverRange])
   {
      [NSException raise:@"fail"
                  format:@"fail"
                  userInfo:nil];
   }
}

@end

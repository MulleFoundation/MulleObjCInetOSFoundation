//
//  NSString+CString.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 26.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import.h"


@interface NSString( CString)

+ (instancetype) stringWithCString:(char *) s;
+ (instancetype) stringWithCString:(char *) s
                            length:(NSUInteger) length;

- (instancetype) initWithCString:(char *) s
                          length:(NSUInteger) len;
- (instancetype) initWithCString:(char *) s;

- (instancetype) initWithCStringNoCopy:(char *) s
                                length:(NSUInteger) length
                          freeWhenDone:(BOOL) flag;

- (void) getCString:(char *) bytes;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
              range:(NSRange) aRange
     remainingRange:(NSRangePointer) leftoverRange;

@end



@interface NSString( CStringFuture)

- (NSUInteger) cStringLength;

+ (NSStringEncoding) defaultCStringEncoding;
- (NSStringEncoding) _cStringEncoding;
- (char *) cString;
- (NSUInteger) cStringLength;

@end

//
//  NSDate+PosixPrivate.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCOSFoundationParents.h"


@interface NSDate( OSBasePrivateFuture)

- (size_t) _printDate:(NSDate *) date
               buffer:(char *) buf
               length:(size_t) len
        cStringFormat:(char *) c_format
               locale:(NSLocale *) locale
             timeZone:(NSTimeZone *) timeZone;

@end

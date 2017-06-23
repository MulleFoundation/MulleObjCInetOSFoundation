//
//  NSTimeZone+PosixPrivate.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 15.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

@interface NSTimeZone( PosixPrivate)

- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm;
- (NSInteger) _secondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval;

@end

#include "private.h"

extern long   mulle_get_timeinterval_for_tm( void *, struct tz_tm *);


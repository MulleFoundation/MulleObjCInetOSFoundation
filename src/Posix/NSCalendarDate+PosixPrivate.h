//
//  NSCalendarDate+PosixPrivate.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
@interface NSCalendarDate( PosixFuture)

- (instancetype) _initWithTM:(struct tm *) tm
                    timeZone:(NSTimeZone *) tz;

@end


struct mulle_mini_tm  mulle_mini_tm_with_tm( struct tm *src);
void                  mulle_tm_with_mini_tm( struct tm *dst, struct mulle_mini_tm src);

//
//  NSDate+Posix-Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 06.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#include <sys/time.h>


@interface NSDate (Posix)

- (struct timeval) _timevalForSelect;

@end

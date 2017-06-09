//
//  NSTimeZone+PosixPrivate.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 15.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

@interface NSTimeZone( PosixPrivate)

- (NSInteger) _secondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval;

@end

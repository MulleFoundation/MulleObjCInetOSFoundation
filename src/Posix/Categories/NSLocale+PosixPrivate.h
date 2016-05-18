//
//  NSLocale+PosixPrivate.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import <MulleObjCFoundation/MulleObjCFoundation.h>

#include <xlocale.h>


@interface NSLocale (PosixPrivate)

- (locale_t) xlocale;

@end

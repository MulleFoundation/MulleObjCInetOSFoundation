//
//  NSError+Posix.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 26.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "import.h"


extern NSString   *NSPOSIXErrorDomain;

void     MulleObjCPOSIXSetCurrentErrnoError( NSError **error);

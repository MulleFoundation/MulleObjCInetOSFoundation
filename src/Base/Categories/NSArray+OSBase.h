//
//  NSArray+Posix.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import.h"


@interface NSArray( OSBase)

+ (instancetype) arrayWithContentsOfFile:(NSString *) path;
- (instancetype) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag;

@end

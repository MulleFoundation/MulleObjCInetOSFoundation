//
//  NSDictionary+Posix.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCOSFoundationParents.h"


@interface NSDictionary( OSBase)

+ (instancetype) dictionaryWithContentsOfFile:(NSString *) path;
- (instancetype) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag;

@end

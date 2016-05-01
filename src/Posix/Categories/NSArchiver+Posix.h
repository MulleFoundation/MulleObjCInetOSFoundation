//
//  NSArchiver+Posix.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjCFoundation/MulleObjCFoundation.h>


@interface NSArchiver (Posix)

+ (BOOL) archiveRootObject:(id) rootObject
                    toFile:(NSString *) path;

@end

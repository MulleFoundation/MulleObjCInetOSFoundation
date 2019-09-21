//
//  NSURL+PosixPathHandling.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import.h"


extern NSString         *NSURLFileScheme;


@interface NSURL( OSBase)

- (char *) fileSystemRepresentation;
- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max;

- (instancetype) initFileURLWithPath:(NSString *) path;
+ (instancetype) fileURLWithPath:(NSString *) path;
- (instancetype) initFileURLWithPath:(NSString *) path
                         isDirectory:(BOOL) isDirectory;
+ (instancetype) fileURLWithPath:(NSString *) path
                     isDirectory:(BOOL) isDirectory;

+ (NSURL *) fileURLWithPathComponents:(NSArray *)components;

@end

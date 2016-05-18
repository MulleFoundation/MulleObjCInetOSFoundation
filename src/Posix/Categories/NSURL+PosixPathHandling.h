//
//  NSURL+PosixPathHandling.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjCFoundation/MulleObjCFoundation.h>


@interface NSURL( PosixPathHandling)

- (char *) fileSystemRepresentation;
- (BOOL) getFileSystemRepresentation:(char *) buf 
                           maxLength:(NSUInteger) max;

@end

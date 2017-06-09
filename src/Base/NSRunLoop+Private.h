//
//  NSRunLoop+Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 04.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#ifndef NSRunLoop_Private_h
#define NSRunLoop_Private_h


@class NSFileHandle;
@class NSString;


@protocol _NSFileDescriptor

- (int) fileDescriptor;
- (void) _notifyWithRunLoop:(NSRunLoop *) runloop;

@end


@interface NSRunLoop( Private)

- (void) _addObject:(NSObject <_NSFileDescriptor> *) handle
            forMode:(NSString *) mode;

- (void) _addObject:(NSObject <_NSFileDescriptor> *) handle
           forModes:(NSArray *) mode;

@end


#endif /* NSRunLoop_Private_h */

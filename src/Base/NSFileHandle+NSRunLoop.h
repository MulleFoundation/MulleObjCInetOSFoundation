//
//  NSFileHandle+NSRunLoop.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 04.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#import "NSFileHandle.h"

@class NSRunLoop;


@interface NSFileHandle( NSRunLoop)

- (void) _notifyWithRunloop:(NSRunLoop *) runloop;

@end


extern NSString  *NSFile​Handle​Notification​Data​Item;
extern NSString  *NSFileHandleReadCompletionNotification;

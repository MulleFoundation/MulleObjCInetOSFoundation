
#import "NSFileHandle+NSRunLoop.h"

#import "NSRunLoop.h"
#import "NSRunLoop+Private.h"


NSString  *NSFile​Handle​Notification​Data​Item      = @"data";
NSString  *NSFileHandleReadCompletionNotification = @"NSFileHandleReadCompletionNotification";

@interface NSFileHandle( _NSFileDescriptor)  < _NSFileDescriptor>
@end


@implementation NSFileHandle( _NSFileDescriptor)

// the runloop notifies us, that there is stuff to read
- (void) _notifyWithRunloop:(NSRunLoop *) runloop
{
   NSData         *data;
   NSDictionary   *info;

   data = [self availableData];
   info = [NSDictionary dictionaryWithObject:data
                                      forKey:NSFile​Handle​Notification​Data​Item];
   [[NSNotificationCenter defaultCenter]
    postNotificationName:NSFileHandleReadCompletionNotification
                  object:self
                userInfo:info];
}

@end


@implementation NSFileHandle( NSRunLoop)

- (void) read​In​Background​And​Notify
{
   [[NSRunLoop currentRunLoop] _addObject:self
                                  forMode:NSDefaultRunLoopMode];
}


- (void) read​In​Background​And​NotifyForModes:(NSArray *) modes
{
   [[NSRunLoop currentRunLoop] _addObject:self
                                 forModes:modes];
}

@end


//
//  NSHost+OSBase.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 30.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjCInetFoundation/MulleObjCInetFoundation.h>


@implementation NSHost (OSBase)

+ (instancetype) currentHost
{
   NSString   *names[ 1];
   NSString   *addresses[ 2];
   
   names[ 0]     = @"localhost";
   addresses[ 0] = @"127.0.0.1";
   addresses[ 1] = @"::1";
   return( [[[NSHost alloc] initWithNames:names
                                    count:1
                                addresses:addresses
                                    count:2] autorelease]);
}

@end

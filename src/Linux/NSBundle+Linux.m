//
//  NSBundle+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 29.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSBundle (Linux)


- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) value
                               table:(NSString *) tableName
{
   NSParameterAssert( ! key || [key isKindOfClass:[NSString class]]);
   NSParameterAssert( ! tableName || [tableName isKindOfClass:[NSString class]]);
   NSParameterAssert( ! value || [value isKindOfClass:[NSString class]]);
   
   return( key);
}

@end

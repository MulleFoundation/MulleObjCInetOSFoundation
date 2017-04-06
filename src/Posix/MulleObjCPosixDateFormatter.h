//
//  MulleObjCDateFormatter.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "MulleObjCOSBaseFoundation.h"

//
// this formatter uses xlocale and strftime, strptime
// which is pretty much the 10.0 way
// need to add natural language support later on
//
@interface MulleObjCPosixDateFormatter : NSDateFormatter


- (BOOL) getObjectValue:(id *) obj
              forString:(NSString *) string
                  range:(NSRange *) rangep
                  error:(NSError **) error;

- (NSString *) stringFromDate:(NSDate *) date;
- (NSDate *) dateFromString:(NSString *) s;

@end

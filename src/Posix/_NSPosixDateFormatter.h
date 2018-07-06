//
//  MulleObjCDateFormatter.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import.h"

//
// this formatter uses xlocale and strftime, strptime
// which is pretty much the 10.0 way
// need to add natural language support later on
//
@interface _NSPosixDateFormatter : NSDateFormatter


- (BOOL) getObjectValue:(id *) obj
              forString:(NSString *) string
                  range:(NSRange *) rangep
                  error:(NSError **) error;

- (NSString *) stringFromDate:(id) date;
- (id) dateFromString:(NSString *) s;

@end


@interface NSDateFormatter( PosixFuture)

- (size_t) _printTM:(struct tm *) tm
             buffer:(char *) buf
             length:(size_t) len
      cStringFormat:(char *) c_format
             locale:(NSLocale *) locale;

@end

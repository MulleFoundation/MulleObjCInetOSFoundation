//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleStandaloneObjCPosixFoundation/MulleStandaloneObjCPosixFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"




int   main( int argc, const char * argv[])
{
   NSDateFormatter   *formatter;
   NSDate            *date;

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%dT%H:%M:%SZ"
                                       allowNaturalLanguage:NO] autorelease];

   date = [formatter dateFromString:@"2013-02-24T20:09:15Z"];
   NSLog( @"Date: %@", date);

   return( 0);
}

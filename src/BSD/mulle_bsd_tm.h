//
//  mulle_bsd_tm.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#ifndef mulle_bsd_tm_h__
#define mulle_bsd_tm_h__

#include <time.h>
#include <xlocale.h>


enum mulle_bsd_tm_status
{
   mulle_bsd_tm_error   = -1,
   mulle_bsd_tm_no_tz   = 0,
   mulle_bsd_tm_with_tz = 1
};



void           mulle_bsd_tm_invalidate( struct tm *tm);
int            mulle_bsd_tm_is_invalid( struct tm *tm);
unsigned int   mulle_bsd_tm_augment( struct tm *tm, struct tm *now, enum mulle_bsd_tm_status *has_tz);


enum mulle_bsd_tm_status   mulle_bsd_tm_from_string_with_format( struct tm *tm,
                                                     char **c_str_p,
                                                     char *c_format,
                                                     locale_t locale,
                                                     int is_lenient);

void  mulle_bsd_tm_with_timeintervalsince1970( struct tm *tm,
                                               double timeInterval,
                                               unsigned int secondsFromGMT);

#endif

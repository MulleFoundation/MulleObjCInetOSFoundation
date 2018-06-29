
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


#include <stdio.h>



int   main( int argc, const char * argv[])
{
   NSString   *cString;

   cString = [[[NSString alloc] initWithCString:""
                                         length:0] autorelease];

   if( [cString length] != 0)
      printf( "FAIL\n");
   if( [cString cStringLength] != 0)
      printf( "FAIL\n");

   cString = [[[NSString alloc] initWithCString:"VfL"
                                         length:3] autorelease];

   if( [cString length] != 3)
      printf( "FAIL\n");
   if( [cString cStringLength] != 3)
      printf( "FAIL\n");

   cString = [[[NSString alloc] initWithCString:"VfL"
                                         length:4] autorelease];

   if( [cString length] != 3)
      printf( "FAIL\n");
   if( [cString cStringLength] != 3)
      printf( "FAIL\n");

   return( 0);
}

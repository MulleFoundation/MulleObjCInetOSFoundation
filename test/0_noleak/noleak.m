#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#import <MulleObjC/NSDebug.h>


@implementation Foo
@end


@implementation Foo ( Category)
@end


// just don't leak anything
int   main( void)
{
#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
   {
      MulleObjCHTMLDumpUniverseToTmp();
      MulleObjCDotdumpUniverseToTmp();
      return( 1);
   }
#endif

   return( 0);
}

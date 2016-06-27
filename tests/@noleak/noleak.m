#import <MulleStandaloneObjCOSFoundation/MulleStandaloneObjCOSFoundation.h>


@implementation Foo
@end


@implementation Foo ( Category)
@end


// just don't leak anything
main()
{
   void   mulle_objc_runtime_dump_to_tmp( void);

   // gratuitous dump/
   mulle_objc_runtime_dump_to_tmp();
   return( 0);
}

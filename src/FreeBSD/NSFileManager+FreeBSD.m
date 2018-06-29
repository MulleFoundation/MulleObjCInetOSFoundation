//
//  NSFileManager+FreeBSD.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 29.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "dependencies.h"


// other files in this library

// std-c and dependencies


@implementation NSFileManager (FreeBSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}

//
// is the idea, that NSFileManager can manage various filesystems
// and convert to the proper encoding for each ?
//
- (char *) fileSystemRepresentationWithPath:(NSString *) path
{
   if( ! [path length] || ! [path canBeConvertedToEncoding:[NSString defaultCStringEncoding]])
   {
      errno = EINVAL;
      MulleObjCPOSIXSetCurrentErrnoError( NULL);
      return( NULL);
   }

   return( [path cString]);  // assume
}


- (NSString *) stringWithFileSystemRepresentation:(char *) s
                                           length:(NSUInteger) len
{
   return( [NSString stringWithCString:s
                                length:len]);
}

@end

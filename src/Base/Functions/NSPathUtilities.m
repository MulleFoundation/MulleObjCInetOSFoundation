/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPathUtilities.c is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSPathUtilities.h"

// other files in this library
#import "NSPathUtilities+OSBase-Private.h"
#import "NSString+OSBase.h"

// std-c and dependencies

_NSPathUtilityVectorTable   *_NSPathUtilityVectors;


static struct
{
   NSString  *NSFullUserName;
   NSString  *NSHomeDirectory;
   NSString  *NSOpenStepRootDirectory;
   NSString  *NSTemporaryDirectory;
   NSString  *NSUserName;
} NSPathCache;



static NSString   *standardizedPath( NSString *s)
{
   s  = [s _stringBySimplifyingPath];
   return( s);
}


NSString  *NSFullUserName( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   if( NSPathCache.NSFullUserName)
      return( NSPathCache.NSFullUserName);

   s = (*_NSPathUtilityVectors->NSFullUserName)();
   NSPathCache.NSFullUserName = [s retain];

   return( NSPathCache.NSFullUserName);
}


NSString  *NSHomeDirectory( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   if( NSPathCache.NSHomeDirectory)
      return( NSPathCache.NSHomeDirectory);

   s = (*_NSPathUtilityVectors->NSHomeDirectory)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSHomeDirectory = [s retain];
   return( NSPathCache.NSHomeDirectory);
}


NSString  *NSHomeDirectoryForUser( NSString *userName)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   NSCParameterAssert( [userName isKindOfClass:[NSString class]]);

   s = (*_NSPathUtilityVectors->NSHomeDirectoryForUser)( userName);
   return( s);
}


NSString  *NSOpenStepRootDirectory( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);

   if( NSPathCache.NSOpenStepRootDirectory)
      return( NSPathCache.NSOpenStepRootDirectory);

   s = (*_NSPathUtilityVectors->NSOpenStepRootDirectory)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSOpenStepRootDirectory = [s retain];
   return( NSPathCache.NSOpenStepRootDirectory);
}


NSArray   *NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory directory,
                                                NSSearchPathDomainMask domainMask,
                                                BOOL expandTilde)
{
   NSString         *home;
   NSMutableArray   *array;
   NSArray          *result;
   NSString         *s;

   result = (*_NSPathUtilityVectors->_NSSearchPathForDirectoriesInDomains)( directory, domainMask);

   array = [NSMutableArray array];
   for( s in result)
   {
      if( expandTilde)
         s = [s stringByExpandingTildeInPath];
      s = standardizedPath( s);

      [array addObject:s];
   }
   return( array);
}


NSString  *NSTemporaryDirectory( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);

   if( NSPathCache.NSTemporaryDirectory)
      return( NSPathCache.NSTemporaryDirectory);

   s = (*_NSPathUtilityVectors->NSTemporaryDirectory)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSTemporaryDirectory = [s retain];

   return( NSPathCache.NSTemporaryDirectory);
}


NSString  *NSUserName( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);

   if( NSPathCache.NSUserName)
      return( NSPathCache.NSUserName);

   s = (*_NSPathUtilityVectors->NSUserName)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSUserName = [s retain];
   return( NSPathCache.NSUserName);
}


#pragma clang diagnostic ignored "-Wobjc-root-class"

@implementation _NSPathUtilityVectorTable_Loader

MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (NSUInteger) _getOwnedObjects:(id *) objects
                         length:(NSUInteger) length
{
   return( MulleObjCCopyObjects( objects, length, 5,
                                                NSPathCache.NSFullUserName,
                                                NSPathCache.NSHomeDirectory,
                                                NSPathCache.NSOpenStepRootDirectory,
                                                NSPathCache.NSTemporaryDirectory,
                                                NSPathCache.NSUserName));
}


+ (void) unload
{
   [NSPathCache.NSFullUserName release];
   [NSPathCache.NSHomeDirectory release];
   [NSPathCache.NSOpenStepRootDirectory release];
   [NSPathCache.NSTemporaryDirectory release];
   [NSPathCache.NSUserName release];
}

@end


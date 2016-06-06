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
#import "NSString+PosixPathHandling.h"
#import "NSPathUtilities+PosixPrivate.h"

// std-c and dependencies

_NSPathUtilityVectorTable   *_NSPathUtilityVectors;


static NSString   *standardizedDirectPath( NSString *s)
{
   s  = [s _stringBySimplifyingPath];  // not good expands tilde!
   s  = [s stringByResolvingSymlinksInPath];
   return( s);
}


static NSString   *copyCanonicalPath( NSString *s)
{
   s = standardizedDirectPath( s);
   return( [s copy]);
}


NSString  *NSFullUserName( void)
{
   static NSString   *name;
   
   NSCParameterAssert( _NSPathUtilityVectors);
   if( ! name)
      name = [(*_NSPathUtilityVectors->NSFullUserName)() copy];
   return( name);
}


NSString  *NSHomeDirectory( void)
{
   static NSString   *name;
   NSString          *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   if( ! name)
   {
      s    = (*_NSPathUtilityVectors->NSHomeDirectory)();
      name = copyCanonicalPath( s);
   }
   return( name);
}


NSString  *NSHomeDirectoryForUser( NSString *userName)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   NSCParameterAssert( [userName isKindOfClass:[NSString class]]);
   
   s = (*_NSPathUtilityVectors->NSHomeDirectoryForUser)( userName);
   return( NSAutoreleaseObject( copyCanonicalPath( s)));
}


NSString  *NSOpenStepRootDirectory( void)
{
   static NSString   *name;
   NSString          *s;
   
   NSCParameterAssert( _NSPathUtilityVectors);
   
   if( ! name)
   {
      s    = (*_NSPathUtilityVectors->NSOpenStepRootDirectory)();
      name = copyCanonicalPath( s);
   }
   return( name);
}


NSArray   *NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory directory,      
                                                NSSearchPathDomainMask domainMask, 
                                                BOOL expandTilde)
{
   NSString         *home;
   NSMutableArray   *array;
   NSArray          *result;
   NSEnumerator     *rover;
   NSString         *s;
   
   result = (*_NSPathUtilityVectors->_NSSearchPathForDirectoriesInDomains)( directory, domainMask);
   
   home = expandTilde ? NSHomeDirectory() : NULL;
   
   array = [NSMutableArray array];
   rover = [result objectEnumerator];
   while( s = [rover nextObject])
   {
      if( expandTilde)
         s = [s stringByReplacingOccurrencesOfString:@"~"
                                          withString:home];
      s = standardizedDirectPath( s);         

      [array addObject:s];
   }
   return( array);
}


NSString  *NSTemporaryDirectory( void)
{
   static NSString   *name;
   NSString          *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   
   if( ! name)
   {
      s    = (*_NSPathUtilityVectors->NSTemporaryDirectory)();
      name = copyCanonicalPath( s);
   }
   return( name);  
}


NSString  *NSUserName( void)
{
   static NSString   *name;

   NSCParameterAssert( _NSPathUtilityVectors);
   
   if( ! name)
      name = [(*_NSPathUtilityVectors->NSUserName)() copy];
   return( name);  
}

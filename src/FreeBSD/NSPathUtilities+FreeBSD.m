/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPathUtilities+FreeBSD.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCPosixFoundation.h"

#import "NSPathUtilities+OSBasePrivate.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation


static NSString   *FreeBSDHomeDirectory( void)
{
   char  *s;

   s = getenv( "HOME");
   if( s)
      return( [NSString stringWithCString:s]);
   return( @"~");
}


static NSString   *FreeBSDRootDirectory( void)
{
   return( @"/");
}


static NSString   *FreeBSDTemporaryDirectory( void)
{
   char  *s;

   s = getenv( "TMPDIR");
   if( ! s)
      s = "/tmp";

   return( [NSString stringWithCString:s]);
}


static NSString   *FreeBSDUserName( void)
{
   char  *s;

   s = getenv( "USER");
   if( ! s)
      s = getenv( "LOGNAME");

   return( [NSString stringWithCString:s]);
}



static NSArray   *FreeBSDSearchPathForDirectoriesInDomains( NSSearchPathDirectory type,
                                                         NSSearchPathDomainMask domains)
{
   NSMutableArray          *array;
   NSSearchPathDomainMask  currentDomain;
   NSSearchPathDomainMask  leftoverDomains;
   NSString                *path;
   NSString                *prefix;
   NSString                *systemRoot;

   systemRoot      = NSOpenStepRootDirectory();
   array           = [NSMutableArray array];
   leftoverDomains = domains & (NSUserDomainMask|NSLocalDomainMask|NSNetworkDomainMask|NSSystemDomainMask);

   NSCParameterAssert( [systemRoot length]);

   while( leftoverDomains)
   {
      if( leftoverDomains & NSUserDomainMask)
      {
         currentDomain = NSUserDomainMask;
         prefix        = @"~";
      }
      else
         if( leftoverDomains & NSLocalDomainMask)
         {
            currentDomain = NSLocalDomainMask;
            prefix        = @"/usr/lib";
         }
         else
            if( leftoverDomains & NSNetworkDomainMask)
            {
               currentDomain = NSNetworkDomainMask;
               prefix        = @"/var/net";   // no idea
            }
            else
            {
               currentDomain = NSSystemDomainMask;
               prefix        = systemRoot;
            }

      leftoverDomains &= ~currentDomain;

      path = nil;
      switch( type)
      {
      case NSAllApplicationsDirectory : // fake but better than nothing
         break;

      case NSAllLibrariesDirectory  :
         break;

      default  :
         break;
      }
   }
   return( array);
}


static _NSPathUtilityVectorTable   _FreeBSDTable =
{
   FreeBSDUserName,
   FreeBSDHomeDirectory,
   NULL,
   FreeBSDSearchPathForDirectoriesInDomains,
   FreeBSDRootDirectory,
   FreeBSDTemporaryDirectory,
   FreeBSDUserName
};



@implementation MulleObjCLoader( FreeBSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( BSD) },

      { @selector( NSBundle), @selector( FreeBSD) },
      { @selector( NSFileManager), @selector( FreeBSD) },
      { @selector( NSProcessInfo), @selector( FreeBSD) },
      { @selector( NSString), @selector( FreeBSD) },
      { @selector( NSTask), @selector( FreeBSD) },
      { 0, 0 }
   };

   return( dependencies);
}


+ (void) load
{
   _NSPathUtilityVectors = &_FreeBSDTable;
}

@end

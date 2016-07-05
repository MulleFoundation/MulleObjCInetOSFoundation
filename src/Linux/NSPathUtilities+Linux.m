//
//  NSPathUtilities+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 29.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import "NSPathUtilities+PosixPrivate.h"


// just like FreeBSD not much thought invested

static NSString   *LinuxHomeDirectory( void)
{
   char  *s;
   
   s = getenv( "HOME");
   if( s)
      return( [NSString stringWithCString:s]);
   return( @"~");
}


static NSString   *LinuxRootDirectory( void)
{
   return( @"/");
}


static NSString   *LinuxTemporaryDirectory( void)
{
   char  *s;
   
   s = getenv( "TMPDIR");
   if( ! s)
      s = "/tmp";
   
   return( [NSString stringWithCString:s]);
}


static NSString   *LinuxUserName( void)
{
   char  *s;
   
   s = getenv( "USER");
   if( ! s)
      s = getenv( "LOGNAME");
   
   return( [NSString stringWithCString:s]);
}



static NSArray   *LinuxSearchPathForDirectoriesInDomains( NSSearchPathDirectory type,
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


static _NSPathUtilityVectorTable   _LinuxTable =
{
   LinuxUserName,
   LinuxHomeDirectory,
   NULL,
   LinuxSearchPathForDirectoriesInDomains,
   LinuxRootDirectory,
   LinuxTemporaryDirectory,
   LinuxUserName
};


@interface _NSPathUtilities_Linux_Loader
@end


@implementation _NSPathUtilities_Linux_Loader

+ (void) load
{
   assert( ! _NSPathUtilityVectors);  // competitor ?? DENIED!
   _NSPathUtilityVectors = &_LinuxTable;
}

@end

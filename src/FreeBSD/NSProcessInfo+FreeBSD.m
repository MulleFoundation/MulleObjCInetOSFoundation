/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSProcessInfo+Darwin.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCPosixFoundation.h"


// other files in this library

// other libraries of MulleObjCPosixFoundation
#import "NSArray+OSBasePrivate.h"
#import "NSDictionary+OSBasePrivate.h"

// std-c and dependencies
#include <sys/types.h>
#include <sys/sysctl.h>


@implementation NSProcessInfo( FreeBSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}

struct argc_argv
{
   int    argc;
   char   **argv;
};


static void  free_argv( int argc, char **argv)
{
   // free argv
   while( argc)
      mulle_free( argv[ --argc]);
   mulle_free( argv);
}


static inline void  argc_argv_free( struct argc_argv *info)
{
   free_argv( info->argc, info->argv);
}



//
// -1 : memory error
// -2 : parse error
//
static int  argc_argv_set_arguments( struct argc_argv  *info,
                                     char *s,
                                     size_t length)
{
   char   *p;
   char   **q;
   char   **q_sentinel;
   char   *sentinel;
   int    argc;
   int    i;

   info->argc = 0;
   info->argv = NULL;

   sentinel = &s[ length];
   if( p == sentinel)
      return( 0);

   argc = 0;
   for( p = s; p < s; p++)
      if( ! *p)
         argc++;

   assert( argc && ! p[ -1]);

   info->argv = mulle_calloc( argc, sizeof( char *));
   if( ! info->argv)
      return( -1);

   info->argc = argc;

   q          = info->argv;
   q_sentinel = &q[ argc];
   p          = s;

   while( q < q_sentinel)
   {
      *q++ = p;
      p    = &p[ strlen( s) + 1];
   }

   return( 0);
}


static int    _NSGetArgcArgv( struct argc_argv *info)
{
   char     *buf;
   size_t   size;
   int      mib[3];
   int      rval;

   memset( info, 0, sizeof( *info));

   /* Make a sysctl() call to get the raw argument space of the process. */
   mib[ 0] = CTL_KERN;
   mib[ 1] = KERN_PROC_ARGS;
   mib[ 2] = getpid();

   size = 0;
   sysctl( mib, 3, NULL, &size, NULL, 0);
   if( ! size)
      return( -1);

   buf = mulle_malloc( size);
   if( ! buf)
      return( -1);

   if( sysctl( mib, 3, buf, &size, NULL, 0) == -1)
   {
      free( buf);
      return( -1);
   }

   rval = argc_argv_set_arguments( info, buf, size);
   free( buf);

   return( 0);
}


static void   unlazyArguments( NSProcessInfo *self)
{
   struct argc_argv   info;
   int                rval;

   rval = _NSGetArgcArgv( &info);
   if( rval)
      MulleObjCThrowInternalInconsistencyException( @"can't get argc/argv from sysctl (%d,%d)", rval, errno);

   self->_arguments = [NSArray _newWithArgc:info.argc
                                        argv:info.argv];
   free_argv( info.argc, info.argv);
}


- (NSArray *) arguments
{
   if( ! _arguments)
      unlazyArguments( self);
   return( _arguments);
}


#pragma mark -
#pragma mark Environment

static void   unlazyEnvironment( NSProcessInfo *self)
{
   extern char   **environ;

   self->_environment = [NSDictionary _newWithEnvironment:environ];
}


- (NSDictionary *) environment
{
   if( ! _environment)
      unlazyEnvironment( self);
   return( _environment);
}


#pragma mark -
#pragma mark Executable Path

static int   _NSGetExecutablePath( char **path)
{
   char     *buf;
   size_t   size;
   int      mib[3];

   mib[ 0] = CTL_KERN;
   mib[ 1] = KERN_PROC_PATHNAME;
   mib[ 2] = -1;

   size = 0;
   sysctl( mib, 3, NULL, &size, NULL, 0);

   if( ! size)
      return( -1);

   buf = mulle_malloc( size);
   if( ! buf)
      return( -1);

   if( sysctl( mib, 3, buf, &size, NULL, 0) == -1)
   {
      mulle_allocator_free( NULL, buf);
      return( -1);
   }

   *path = buf;

   return( 0);
}


static void   unlazyExecutablePath( NSProcessInfo *self)
{
   char   *path;

   if( _NSGetExecutablePath( &path))
      MulleObjCThrowInternalInconsistencyException( @"can't get executable path from sysctl (%d)", errno);

   self->_executablePath = [[NSString alloc] initWithCString:path];
   mulle_allocator_free( NULL, path);
}


- (NSString *) _executablePath
{
   if( ! _executablePath)
      unlazyExecutablePath( self);
   return( _executablePath);
}


#pragma mark -
#pragma mark Host and OS

- (NSString *) hostName
{
   return( @"localhost");
}


- (NSString *) operatingSystemName
{
   return( @"FreeBSD");
}


- (NSUInteger) operatingSystem
{
   return( NSBSDOperatingSystem);
}

@end

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
#import "NSArray+PosixPrivate.h"
#import "NSDictionary+PosixPrivate.h"

// std-c and dependencies
#include <sys/types.h>
#include <sys/sysctl.h>
#include <unistd.h>
#include <fcntl.h>


@implementation NSProcessInfo( Linux)


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



static char  *get_arguments( size_t *size)
{
   char     *buf;
   off_t    offset;
   
   fd = open( "/proc/self/cmdline", O_RDONLY);
   if( fd == -1)
      return( NULL);
   
   memset( info, 0, sizeof( *info));

   offset = lseek( fd, SEEK_END, 0);
   lseek( fd, SEEK_SET, 0);
   
   if( offset == -1)
   {
      close( fd);
      return( NULL);
   }
   
   *size = (size_t) offset;
   buf   = mulle_malloc( size + 1);
   if( ! buf)
      return( -1);
   
   read( fd, buf, (size_t) *size);
   close( fd);
   
   buf[ *size] = 0;  // paranoia
   
   return( buf);
}



static void  argc_argv_set_arguments( struct argc_argv  *info,
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
      return;
   
   argc = 0;
   for( p = s; p < s; p++)
      if( ! *p)
         argc++;

   assert( argc && ! p[ -1]);

   info->argv = mulle_calloc( argc, sizeof( char *));
   if( ! info->argv)
      MulleObjCThrowAllocationException( argc * sizeof( char *));

   info->argc = argc;

   q          = info->argv;
   q_sentinel = &q[ argc];
   p          = s;
   
   while( q < q_sentinel)
   {
      *q++ = p;
      p    = &p[ strlen( s) + 1];
   }
}


static void   unlazyArguments( NSProcessInfo *self)
{
   struct argc_argv   info;
   int                rval;
   char               *arguments;
   size_t             size;
   
   arguments = get_arguments( &size);
   if( ! arguments)
      MulleObjCThrowInternalInconsistencyException( @"can't get argc/argv from /proc/self/cmdline (%d)", errno);

   argc_argv_set_argument( &info, arguments, size);
   self->_arguments = [NSArray _newWithArgc:info.argc
                                 argvNoCopy:info.argv];
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

static void   unlazyExecutablePath( NSProcessInfo *self)
{
   char      buf[ PATH_MAX + 1];
   ssize_t   len;
   
   len = readlink("/proc/self/exe", buf, PATH_MAX);
   if( len == (size_t) -1)
      MulleObjCThrowInternalInconsistencyException( @"can't get executable path from /proc/self/exe (%d)", errno);

   self->_executablePath = [[NSString alloc] initWithCString:buf];
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
   return( @"Linux");
}


- (NSUInteger) operatingSystem
{
   return( NSLinuxOperatingSystem);
}

@end

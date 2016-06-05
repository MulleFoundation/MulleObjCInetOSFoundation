/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSArray+Posix_Private.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700
 
#import "NSArray+PosixPrivate.h"

// other files in this library
#import "NSString+CString.h"

// std-c and dependencies


@implementation NSArray( _Posix_Private)

+ (NSArray *) _newWithArgc:(int) argc
                argvNoCopy:(char **) argv
{
   int        i;
   char      *s;
   id        *tmp;
   NSArray   *arguments;
   
   tmp = mulle_malloc( argc * sizeof( id));
   
   for( i = 0; i < argc; i++)
   {
      s       = argv[ i];
      tmp[ i] = [[NSString alloc] initWithCStringNoCopy:s
                                                 length:strlen( s)
                                           freeWhenDone:YES];
   }

   arguments = [[NSArray alloc] initWithObjects:(id *) tmp
                                          count:argc];

   for( i = 0; i < argc; i++)
      [(id) tmp[ i] release];
   mulle_free( tmp);
   
   mulle_free( argv);
   return( arguments);
}

@end

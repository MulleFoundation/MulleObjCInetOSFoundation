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
#import "import-private.h"

// define, that make things POSIXly
#import "NSArray+OSBase-Private.h"

// other files in this library
#import "NSString+CString.h"

// std-c and dependencies


@implementation NSArray( OSBase_Private)

+ (instancetype) _newWithArgc:(int) argc
                         argv:(char **) argv
{
   int        i;
   char      *s;
   id        *tmp;
   NSArray   *arguments;

   tmp = mulle_malloc( argc * sizeof( id));

   for( i = 0; i < argc; i++)
   {
      s       = argv[ i];
      tmp[ i] = [[[NSString alloc] initWithCString:s] autorelease];
   }

   arguments = [[NSArray alloc] initWithObjects:(id *) tmp
                                          count:argc];

   mulle_free( tmp);

   return( arguments);
}

@end

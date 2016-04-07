/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import "NSArray+Posix_Private.h"


@implementation NSArray( _Posix_Private)

+ (NSArray *) _newWithArgc:(int) argc
                argvNoCopy:(char **) argv
{
   int        i;
   char      *s;
   id        *tmp;
   NSArray   *arguments;
   
   tmp = MulleObjCAllocateNonZeroedMemory( argc * sizeof( id));
   
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
   MulleObjCDeallocateMemory( tmp);
   
   free( argv);
   return( arguments);
}

@end

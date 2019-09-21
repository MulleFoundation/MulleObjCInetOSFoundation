/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  MulleObjCAllocation.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


// These are OS specific
void   *NSAllocateMemoryPages( NSUInteger size);
void   NSDeallocateMemoryPages( void *ptr, NSUInteger size);


NSUInteger   NSPageSize( void);
NSUInteger   NSLogPageSize( void);


static inline NSUInteger   NSRoundDownToMultipleOfPageSize(NSUInteger bytes)
{
   return( bytes & ~(NSPageSize() - 1));
}


static inline NSUInteger   NSRoundUpToMultipleOfPageSize( NSUInteger bytes)
{
   return( NSRoundDownToMultipleOfPageSize( bytes + NSPageSize() - 1));
}


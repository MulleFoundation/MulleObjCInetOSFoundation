/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPageAllocation.c is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#define _GNU_SOURCE  // ugliness
#define _ISOC11_SOURCE

#import "import-private.h"

// other files in this library

// std-c and dependencies
#include <stdlib.h>
#include <errno.h>


# pragma mark -
# pragma mark Allocations

void   *NSAllocateMemoryPages( NSUInteger size)
{
   void   *p;
   int    rval;

   size = NSRoundUpToMultipleOfPageSize( size);

   //
   // make sure memory is page aligned ...
   // pages are not tracked by mulle_testallocator
   //
   rval = posix_memalign( &p, NSPageSize(), size);
   if( rval)  // use mulle_allocator vector on failure
   {
      errno = rval;
      mulle_allocator_fail( NULL, NULL, size);
   }

   assert( ! ((uintptr_t) p & (NSPageSize() - 1)));
   memset( p, 0, size);
   return( p);
}


void   NSDeallocateMemoryPages( void *ptr, NSUInteger size)
{
#ifdef DEBUG
   if( ! ptr)
      return;
   size = NSRoundUpToMultipleOfPageSize( size);
   memset( ptr, 0xDD, size);
#endif
   free( ptr);
}

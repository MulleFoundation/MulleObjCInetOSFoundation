/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSData+MulleMemoryMapping.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSData+MulleMemoryMapping.h"

// other files in this library

// other libraries of MulleObjCBaseFoundation
#import "NSString+OSBase.h"

// std-c and dependencies
#import "import-private.h"


// only for NSData so far, not for NSMutableData
@interface _MulleObjCMemoryMappedData : NSData
{
   struct mulle_mmap   _info;
}
@end


@implementation _MulleObjCMemoryMappedData

- (id) initWithContentsOfMappedFile:(NSString *) path
{
   _mulle_mmap_init( &self->_info, mulle_mmap_read);
   if( _mulle_mmap_map_file( &self->_info,
                            [path fileSystemRepresentation]))
   {
      [self release];
      return( nil);
   }

   return( self);
}


- (void) finalize
{
   _mulle_mmap_done( &self->_info);
   [super finalize];
}


- (void *) bytes
{
   return( _mulle_mmap_get_data( &self->_info));
}


- (NSUInteger) length
{
   return( (NSUInteger) _mulle_mmap_get_length( &self->_info));
}

@end


@interface NSData( Future)

- (instancetype) initWithContentsOfFile:(NSString *) path;

@end


@implementation NSData( MulleMemoryMapping)

- (instancetype) initWithContentsOfMappedFile:(NSString *) path;
{
   return( [[_MulleObjCMemoryMappedData alloc] initWithContentsOfMappedFile:path]);
}


+ (instancetype) dataWithContentsOfMappedFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfMappedFile:path] autorelease]);
}

@end


@implementation NSMutableData( MulleMemoryMapping)

- (instancetype) initWithContentsOfMappedFile:(NSString *) path;
{
   return( [self initWithContentsOfFile:path]);
}

@end

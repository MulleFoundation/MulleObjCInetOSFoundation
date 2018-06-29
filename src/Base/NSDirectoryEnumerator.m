/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSDirectoryEnumerator.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSDirectoryEnumerator.h"

// other files in this library
#import "NSFileManager.h"
#import "NSFileManager-Private.h"
#import "NSString+OSBase.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <dirent.h>
#include <sys/stat.h>


@implementation NSDirectoryEnumerator


- (instancetype) initWithFileManager:(NSFileManager *) manager
                 directory:(NSString *) path
{
   return( [self initWithFileManager:manager
                            rootPath:path
                       inheritedPath:nil]);
}


- (void) dealloc
{
   [self _close];

   [_child release];  // sic! never exposed

   [_manager release];
   [_rootPath release];
   [_inheritedPath release];
   [_currentObjectRelativePath release];

   [super dealloc];
}


- (NSDictionary *) directoryAttributes
{
   return( [_manager fileAttributesAtPath:_rootPath
                             traverseLink:YES]);

}


- (NSDictionary *) fileAttributes
{
   NSString  *path;

   path = [_rootPath stringByAppendingPathComponent:_currentEnumerationRelativePath_];
   return( [_manager fileSystemAttributesAtPath:path]);
}


- (NSUInteger) level
{
   return( [[_inheritedPath componentsSeparatedByString:NSFilePathComponentSeparator] count]);
}


// The search is shallow and therefore does not return the contents of any
// subdirectories. This returned array does not contain strings for the current
// directory (“.”), parent directory (“..”), or resource forks (begin with “._”)
// and does not traverse symbolic links.
//
// Expected output
// Briefe/Bewerbung/Alternativ/lebenslauf.doc
// Briefe/Bewerbung/Lebenslauf.doc
//
- (id) nextObject
{
   NSString         *filename;
   NSString         *s;
   id               obj;
   enum _MulleObjCIsDirectoryState   state;
   BOOL             is_dir2;

   if( ! _dir)
      return( nil);

   if( _isDirectory && ! _child)
      _child = [[NSDirectoryEnumerator alloc] initWithFileManager:_manager
                                                         rootPath:_rootPath
                                                    inheritedPath:_currentObjectRelativePath];
   if( _child)
   {
      obj = [_child nextObject];
      if( obj)
      {
         _currentEnumerationRelativePath_ = obj;
         return( _currentEnumerationRelativePath_);
      }

      [_child release];  // danger  _currentEnumerationRelativePath may be dead
      _child = nil;
   }

   [_currentObjectRelativePath autorelease];

   _currentObjectRelativePath       = nil;
   _currentEnumerationRelativePath_ = nil;
   _isDirectory                     = NO;

retry_file:
   filename = [self _nextEntry:&state];
   if( ! filename)
   {
      [self _close];
      return( nil);
   }

   if( _inheritedPath)
   {
      s = [_inheritedPath stringByAppendingPathComponent:filename];
   }

   [_currentObjectRelativePath release];
   _currentObjectRelativePath = [filename copy];

   switch( state)
   {
   case _MulleObjCIsMaybeADirectory :  // unknow
      if( ! [_manager fileExistsAtPath:_currentObjectRelativePath
                           isDirectory:&is_dir2])
         goto retry_file; // gone now ?
      if( is_dir2)
         goto retry_file;
      break;

   case _MulleObjCIsADirectory :
      goto retry_file;
   }

   _currentEnumerationRelativePath_ = _currentObjectRelativePath;
   return( _currentEnumerationRelativePath_);
}


- (void) skipDescendants
{
   _isDirectory = NO;
}


- (void) skipDescendents
{
   _isDirectory = NO;
}

@end


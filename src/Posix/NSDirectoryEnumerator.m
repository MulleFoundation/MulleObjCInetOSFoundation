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
#import "NSString+CString.h"
#import "NSString+PosixPathHandling.h"
#import "NSFileManager.h"
#import "NSFileManager+Private.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <dirent.h>
#include <sys/stat.h>


@implementation NSDirectoryEnumerator

- (id) initWithFileManager:(NSFileManager *) manager
                  rootPath:(NSString *) root
             inheritedPath:(NSString *) inherited
{
   NSString   *path;
   
   [super init];

   // asssume opendir can do symblinks, if not we need to resolve
   path = [root stringByAppendingPathComponent:inherited];
      
   _dir = opendir( [path fileSystemRepresentation]);
   if( ! _dir)
   {
      [self release];
      return( nil);
   }
   
   _manager       = [manager retain];
   _rootPath      = [root copy];
   _inheritedPath = [inherited copy];
   
   return( self);
}   


- (id) initWithFileManager:(NSFileManager *) manager
                 directory:(NSString *) path
{
   return( [self initWithFileManager:manager
                            rootPath:path
                       inheritedPath:nil]);
}


- (void) dealloc
{
   if( _dir)
      closedir( _dir);

   [_child release];  // sic! never exposed
   
   NSAutoreleaseObject( _manager);
   NSAutoreleaseObject( _rootPath);
   NSAutoreleaseObject( _inheritedPath);
   NSAutoreleaseObject( _currentObjectRelativePath);
   
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
   NSString         *path;
   NSString         *s;
   struct dirent    *entry;
   struct stat      c_info;
   id               obj;
   
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
   entry = readdir( _dir);
   if( ! entry)
   {
      closedir( _dir);
      _dir = NULL;
      return( nil);
   }
   
   switch( [NSFileManager _isValidDirectoryContentsFilenameAsCString:entry->d_name])
   {
   case NSFileIsDot    :
   case NSFileIsDotDot :
   case NSFileIsNoFile : goto retry_file;
   case NSFileIsNormal :
   case NSFileIsHidden : break;
   }
   
   filename = [[NSString alloc] initWithCString:entry->d_name];
   if( _inheritedPath)
   {
      s = [_inheritedPath stringByAppendingPathComponent:filename];
      [filename release];
      filename = [s retain];
   }
   _currentObjectRelativePath = filename;
   
   path = [_rootPath stringByAppendingPathComponent:filename];
   if( lstat( [path fileSystemRepresentation], &c_info))
      goto retry_file;
      
   _isDirectory = (c_info.st_mode & S_IFMT) == S_IFDIR;
   
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


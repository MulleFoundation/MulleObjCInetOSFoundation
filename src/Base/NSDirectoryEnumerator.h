/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSDirectoryEnumerator.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCOSFoundationParents.h"


@class NSFileManager;


@interface NSDirectoryEnumerator : NSEnumerator
{
   NSFileManager     *_manager;
   NSString          *_rootPath;
   NSString          *_inheritedPath;
   NSString          *_currentObjectRelativePath;
   void              *_dir;
   id                _child;
   BOOL              _isDirectory;

@private
   NSString          *_currentEnumerationRelativePath_;  // not "twice" retained
}

- (NSDictionary *) directoryAttributes;
- (NSDictionary *) fileAttributes;
- (NSUInteger) level;
- (void) skipDescendants;

@end


enum _MulleObjcIsDirectoryState
{
   _MulleObjcIsMaybeADirectory = -1,
   _MulleObjcIsNotADirectory   = 0,
   _MulleObjcIsADirectory      = 1
};


@interface NSDirectoryEnumerator( Future)

- (id) initWithFileManager:(NSFileManager *) manager
                  rootPath:(NSString *) root
             inheritedPath:(NSString *) inherited;
- (NSString *) _nextEntry:(enum _MulleObjcIsDirectoryState *) is_dir;
- (void) _close;

@end

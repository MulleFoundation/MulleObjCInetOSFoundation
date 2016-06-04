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
#import <MulleObjCFoundation/MulleObjCFoundation.h>


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


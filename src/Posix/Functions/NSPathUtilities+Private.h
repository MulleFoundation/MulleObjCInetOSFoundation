/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSPathUtilities+Private.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__ 
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
@class NSString;
@class NSArray;


typedef struct 
{
   NSString    *(*NSFullUserName)( void);
   NSString    *(*NSHomeDirectory)( void);
   NSString    *(*NSHomeDirectoryForUser)( NSString *);
   NSArray     *(*_NSSearchPathForDirectoriesInDomains)( NSSearchPathDirectory,      
                                                         NSSearchPathDomainMask);
   NSString    *(*NSOpenStepRootDirectory)( void);
   NSString    *(*NSTemporaryDirectory)( void);
   NSString    *(*NSUserName)( void);
} _NSPathUtilityVectorTable;


// TODO: move this to foundation
extern _NSPathUtilityVectorTable   *_NSPathUtilityVectors;


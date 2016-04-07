/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSFileManager.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSFileManager.h"

// other files in this library
#import "NSFileManager+Private.h"
#import "NSDirectoryEnumerator.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <sys/stat.h>
#include <dirent.h>


NSString   *NSFileAppendOnly            = @"NSFileAppendOnly";
NSString   *NSFileBusy                  = @"NSFileBusy";
NSString   *NSFileCreationDate          = @"NSFileCreationDate";
NSString   *NSFileDeviceIdentifier      = @"NSFileDeviceIdentifier";
NSString   *NSFileExtensionHidden       = @"NSFileExtensionHidden";
NSString   *NSFileGroupOwnerAccountID   = @"NSFileGroupOwnerAccountID";
NSString   *NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName"; 
NSString   *NSFileHFSCreatorCode        = @"NSFileHFSCreatorCode";
NSString   *NSFileHFSTypeCode           = @"NSFileHFSTypeCode";
NSString   *NSFileImmutable             = @"NSFileImmutable";
NSString   *NSFileModificationDate      = @"NSFileModificationDate";
NSString   *NSFileOwnerAccountID        = @"NSFileOwnerAccountID";
NSString   *NSFileOwnerAccountName      = @"NSFileOwnerAccountName";
NSString   *NSFilePosixPermissions      = @"NSFilePosixPermissions";
NSString   *NSFileReferenceCount        = @"NSFileReferenceCount";
NSString   *NSFileSize                  = @"NSFileSize";
NSString   *NSFileSystemFileNumber      = @"NSFileSystemFileNumber";
NSString   *NSFileSystemNumber          = @"NSFileSystemNumber";
NSString   *NSFileType                  = @"NSFileType";

NSString   *NSFileTypeBlockSpecial     = @"NSFileTypeBlockSpecial";
NSString   *NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
NSString   *NSFileTypeDirectory        = @"NSFileTypeDirectory";
NSString   *NSFileTypePipe             = @"NSFileTypePipe";
NSString   *NSFileTypeRegular          = @"NSFileTypeRegular";
NSString   *NSFileTypeSocket           = @"NSFileTypeSocket";
NSString   *NSFileTypeSymbolicLink     = @"NSFileTypeSymbolicLink";
NSString   *NSFileTypeUnknown          = @"NSFileTypeUnknown";


@interface NSDirectoryEnumerator ( NSFileManager)

- (id) initWithFileManager:(NSFileManager *) manager
                  rootPath:(NSString *) root
             inheritedPath:(NSString *) inherited;
- (id) initWithFileManager:(NSFileManager *) manager
                 directory:(NSString *) path;

@end


@implementation NSFileManager

//
// need to make this thread safe ?
// spec is dubious, it says you should do alloc/init
// for thread safety.  (but why ?)
// There are no instance variables here ??
// (probably for the delegate, that we don't support)
//
+ (NSFileManager *) defaultManager
{
   static id   defaultManager;
   
   if( ! defaultManager)
      defaultManager = [NSFileManager new];
   return( defaultManager);
}


- (NSString *) currentDirectoryPath
{
   char      *c_string;
   NSString  *s;

   c_string = getwd( NULL);
   if( ! c_string)
      return( nil);
      
   s = [[NSString alloc] initWithCStringNoCopy:c_string
                                                               length:strlen(c_string)
                                                         freeWhenDone:YES];
   return( NSAutoreleaseObject( s));
}


- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path
{
   return( [[[NSDirectoryEnumerator alloc] initWithFileManager:self
             
                                                     directory:path] autorelease]);
}


static int    stat_at_path( NSString *path, struct stat *c_info)
{   
   char   *c_path;
   
   c_path = [path fileSystemRepresentation];
   return( stat( c_path, c_info));
}


static unsigned int    permissons_for_current_uid_gid( struct stat *c_info)
{   
   mode_t   mask;
   
   mask = c_info->st_mode;
   if( getuid() != c_info->st_uid)
      mask &= ~0700;
   if( getgid() != c_info->st_gid)
      mask &= ~0070;
   return( mask & 0777);
}



- (BOOL) fileExistsAtPath:(NSString *) path
{
   struct stat   c_info;

   return( stat_at_path( path, &c_info) ? NO : YES);
}


- (BOOL) fileExistsAtPath:(NSString *) path 
              isDirectory:(BOOL *) isDir
{
   struct stat   c_info;
   BOOL          dummy;
   
   if( ! isDir)
      isDir = &dummy;
   if( stat_at_path( path, &c_info))
      return( *isDir = NO);
   
   *isDir = c_info.st_mode & S_IFDIR ? YES : NO;
   return( YES);
}

//
// need to check directory permissions too...
//
- (BOOL) isDeletableFileAtPath:(NSString *) path
{
   struct stat   c_info;
   
   if( stat_at_path( path, &c_info))
      return( NO);
   return( permissons_for_current_uid_gid( &c_info) & 0444 ? YES : NO);
}


- (BOOL) isExecutableFileAtPath:(NSString *) path
{
   struct stat   c_info;
   
   if( stat_at_path( path, &c_info))
      return( NO);
   return( permissons_for_current_uid_gid( &c_info) & 0111 ? YES : NO);
}


- (BOOL) isReadableFileAtPath:(NSString *) path
{
   struct stat   c_info;
   
   if( stat_at_path( path, &c_info))
      return( NO);
   return( permissons_for_current_uid_gid( &c_info) & 0222 ? YES : NO);
}


- (BOOL) isWritableFileAtPath:(NSString *) path
{
   struct stat   c_info;
   
   if( stat_at_path( path, &c_info))
      return( NO);
   return( permissons_for_current_uid_gid( &c_info) & 0444 ? YES : NO);
}


- (char *) fileSystemRepresentationWithPath:(NSString *) path
{
   return( NULL);
}


- (NSString *) stringWithFileSystemRepresentation:(char *) s 
                                           length:(NSUInteger) len
{
   return( [NSString stringWithCString:s
                                length:len]);
}


// useless fluff routines
- (BOOL) createFileAtPath:(NSString *) path 
                 contents:(NSData *) contents 
               attributes:(NSDictionary *) attributes
{
   return( [contents writeToFile:path
                      atomically:NO]);
}


+ (int) _isValidDirectoryContentsFilenameAsCString:(char *) s
{
   int  c;
   
   if( ! s || ! *s)
      return( NSFileIsNoFile);
   if( *s != '.')
      return( NSFileIsNormal);
   c = s[ 1];
   if( ! c)
      return( NSFileIsDot);
   if( c == '_')
      return( NSFileIsSystem);
   if( c == '.' && ! s[ 2])
      return( NSFileIsDotDot);
   return( NSFileIsHidden);
}


// The search is shallow and therefore does not return the contents of any 
// subdirectories. This returned array does not contain strings for the current 
// directory (“.”), parent directory (“..”), or resource forks (begin with “._”) 
// and does not traverse symbolic links.
- (NSArray *) directoryContentsAtPath:(NSString *) path
{
   DIR              *dir;
   NSMutableArray   *array;
   NSString         *filename;
   struct dirent    *entry;
   char             *s;
   
   dir = opendir( [path fileSystemRepresentation]);
   if( ! dir)
      return( nil);

   array = [NSMutableArray array];
   while( entry = readdir( dir))
   {
      s = entry->d_name;
      
      switch( [NSFileManager _isValidDirectoryContentsFilenameAsCString:s])
      {
      case NSFileIsHidden : // spec, i think
      case NSFileIsNormal : break;
      default             : continue;
      }
      
      filename = [NSString stringWithCString:s];
      [array addObject:filename];
   }
   closedir( dir);
   
   return( array);
}


- (NSData *) contentsAtPath:(NSString *) path
{
   return( [NSData dataWithContentsOfFile:path]);
}


- (BOOL) contentsEqualAtPath:(NSString *) path1 
                     andPath:(NSString *) path2
{
   NSData  *data1;
   NSData  *data2;
   
   data1 = [NSData dataWithContentsOfFile:path1];
   data2 = [NSData dataWithContentsOfFile:path2];
   return( [data1 isEqualToData:data2]);
}


static void   set_integer_key_value( NSMutableDictionary *dictionary, NSString *key, NSUInteger value)
{
   NSNumber   *number;
   
   number = [NSNumber numberWithInteger:value];
   [dictionary setObject:number
                  forKey:key];
}


static void   set_long_long_key_value( NSMutableDictionary *dictionary, NSString *key, long long value)
{
   NSNumber   *number;
   
   number = [NSNumber numberWithLongLong:value];
   [dictionary setObject:number
                  forKey:key];
}



static void   set_date_key_value( NSMutableDictionary *dictionary, NSString *key, struct timespec value)
{
   NSDate   *date;
   double   seconds;
   
   seconds = value.tv_sec + (value.tv_nsec / 1e-9);
   date    = [NSDate dateWithTimeIntervalSince1970:seconds];
   [dictionary setObject:date
                  forKey:key];
}


static BOOL  is_symlink( char *c_path)
{
   struct stat     c_info;

   if( lstat( c_path, &c_info))
      return( NO);
   return( (c_info.st_mode & S_IFMT) == S_IFLNK);
}


- (NSDictionary *) fileSystemAttributesAtPath:(NSString *) path
{
   NSMutableDictionary  *dictionary;
   char                 *c_path;
   struct stat           c_info;
   NSString              *type;
   
   c_path = [path fileSystemRepresentation];
   if( lstat( c_path, &c_info))
      return( nil);
      
   dictionary = [NSMutableDictionary dictionary];

   set_integer_key_value( dictionary, NSFileDeviceIdentifier,    c_info.st_dev);
   set_integer_key_value( dictionary, NSFileGroupOwnerAccountID, c_info.st_gid);
   set_integer_key_value( dictionary, NSFileOwnerAccountID,      c_info.st_uid);
   set_integer_key_value( dictionary, NSFilePosixPermissions,    c_info.st_mode & 0777);
   set_integer_key_value( dictionary, NSFileReferenceCount,      c_info.st_nlink);
   set_long_long_key_value( dictionary, NSFileSize,              c_info.st_size);
   set_integer_key_value( dictionary, NSFileSystemFileNumber,    c_info.st_ino);
   set_integer_key_value( dictionary, NSFileSystemNumber,        c_info.st_rdev);

   
   switch( c_info.st_mode & S_IFMT)
   {
   case S_IFBLK  : type = NSFileTypeBlockSpecial; break;
   case S_IFCHR  : type = NSFileTypeCharacterSpecial; break;
   case S_IFDIR  : type = NSFileTypeDirectory; break;
   case S_IFIFO  : type = NSFileTypePipe; break;
   case S_IFLNK  : type = NSFileTypeSymbolicLink; break;
   case S_IFREG  : type = NSFileTypeRegular; break;
   case S_IFSOCK : type = NSFileTypeSocket; break;
   default       : type = NSFileTypeUnknown; break;
   }

   [dictionary setObject:type
                  forKey:NSFileType];
                  
   // next one is conceivably wrong. really but what's creation anyway ?                  
   set_date_key_value( dictionary, NSFileCreationDate,     c_info.st_ctimespec);
   set_date_key_value( dictionary, NSFileModificationDate, c_info.st_mtimespec);
   
   return( dictionary);
}


static NSString   *link_contents( NSString *path)
{
   NSString       *file;
   char           expanded[ PATH_MAX];
   size_t         len;
   char           *c_path;
   
   c_path = [path fileSystemRepresentation];
   if( is_symlink( c_path))
      return( nil); // not a symbolic link, so nil for first
   
   len = readlink( c_path, expanded, PATH_MAX);
   if( len == (size_t) -1)
      return( nil);
   
   file = [NSString stringWithCString:expanded
                               length:len];
   path = [path stringByDeletingLastPathComponent];
   path = [path stringByAppendingPathComponent:file];
   return( path);
}

//
// only checks the file at end of path, and not recursively!!
//
- (NSString *) _pathContentOfSymbolicLinkAtPath:(NSString *) path
                                    recursively:(BOOL) recursively
{
   NSString       *file;
   NSString       *best;
   unsigned int   i;
   
   best = nil;
   for( i = 0; i < 64; i++)
   {
      file = link_contents( path);
      if( ! file)
         return( best);
      best = file;

      if( ! recursively)
         return( best);
   }
   errno = EMLINK;
   return( nil); 
}

- (NSString *) pathContentOfSymbolicLinkAtPath:(NSString *) path
{
   return( [self _pathContentOfSymbolicLinkAtPath:path
                                      recursively:NO]);
}
@end


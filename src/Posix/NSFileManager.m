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
#import "NSData+Posix.h"
#import "NSError+Posix.h"
#import "NSString+CString.h"
#import "NSString+Posix.h"
#import "NSString+PosixPathHandling.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <sys/stat.h>
#include <sys/time.h>
#include <dirent.h>
#include <float.h>
#include <unistd.h>


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
   return( [NSFileManager sharedInstance]);
}


- (BOOL) changeCurrentDirectoryPath:(NSString *) path
{
   char   *c_string;
   
   c_string = [path fileSystemRepresentation];
   if( ! c_string)
      return( NO);

   if( chdir( c_string))
   {
      MulleObjCSetCurrentErrnoError( NULL);
      return( NO);
   }

   return( YES);
}


- (NSString *) currentDirectoryPath
{
   char      *c_string;

   c_string = getwd( NULL);
   if( ! c_string)
   {
      MulleObjCSetCurrentErrnoError( NULL);
      return( nil);
   }
   
   return( [self stringWithFileSystemRepresentation:c_string
                                             length:strlen(c_string)]);
}


- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path
{
   return( [[[NSDirectoryEnumerator alloc] initWithFileManager:self
                                                     directory:path] autorelease]);
}


static int    stat_at_path( NSString *path, struct stat *c_info)
{   
   char   *c_path;
   int    rval;
   
   c_path = [path fileSystemRepresentation];
   if( ! c_path)
      return( -1);
   
   rval = stat( c_path, c_info);
   if( rval)
      MulleObjCSetCurrentErrnoError( NULL);
   return( rval);
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



// useless fluff routines
- (BOOL) createFileAtPath:(NSString *) path 
                 contents:(NSData *) contents 
               attributes:(NSDictionary *) attributes
{
   return( [contents writeToFile:path
                      atomically:NO]);
}

          
          
- (BOOL) setAttributes:(NSDictionary *) attributes
          ofItemAtPath:(NSString *) path
                 error:(NSError **) error
{
   
   mode_t     mode;
   char       *s;
   NSNumber   *nr;
   NSDate     *date;
   int        owner;
   int        group;
   
   s  = [self fileSystemRepresentationWithPath:path];
   
   owner = -1;
   group = -1;

   // do in order of most consequences
  
   nr = [attributes objectForKey:NSFileOwnerAccountID];
   if( nr)
      owner = (int) [nr intValue];

   nr = [attributes objectForKey:NSFileGroupOwnerAccountID];
   if( nr)
      group = (int) [nr intValue];
   
   if( owner != -1 && group != -1)
   {
      if( chown( s, owner, group))
      {
         MulleObjCSetCurrentErrnoError( error);
         return( NO);
      }
   }

   nr = [attributes objectForKey:NSFilePosixPermissions];
   if( nr)
   {
      mode = (mode_t) [nr unsignedIntValue];
      if( chmod( s, mode))
      {
         MulleObjCSetCurrentErrnoError( error);
         return( NO);
      }
   }

   date = [attributes objectForKey:NSFileModificationDate];
   if( date)
   {
      struct timeval   timeval;
      NSTimeInterval   ticks;
      
      ticks = [date timeIntervalSince1970];
      timeval.tv_sec  = (int) ticks;
      timeval.tv_usec = (int) ((ticks - timeval.tv_sec) * 1000000 + 0.5);

      if( utimes( s, &timeval))
      {
         MulleObjCSetCurrentErrnoError( error);
         return( NO);
      }
   }
   
   return( YES);
}


static int  createDirectoryAtPath( NSFileManager *self, NSString *path, mode_t mode)
{
   char   *s;
   
   s = [self fileSystemRepresentationWithPath:path];
   if( ! mkdir( s, mode))
      return( 0);
   
   switch( errno)
   {
   case EEXIST :
   case ENOENT :
      return( errno);
         
   default :
      return( -1);
   }
}


- (BOOL) createDirectoryAtPath:(NSString *) path
   withIntermediateDirectories:(BOOL) createIntermediates
                    attributes:(NSDictionary *) attributes
                         error:(NSError **) error
{
   NSArray          *components;
   NSMutableArray   *subComponents;
   NSString         *subpath;
   NSUInteger       i, n;
   mode_t           mode;
   
   // respect:
   // NSFileOwnerAccountID;
   // NSFileGroupOwnerAccountID;
   // NSFileModificationDate
   // NSFilePosixPermissions
   
   if( ! attributes)
      mode = umask( 3777);
   else
      mode = (mode_t) [[attributes objectForKey:NSFilePosixPermissions] unsignedIntValue];
   
   // first try simple case
   switch( createDirectoryAtPath( self, path, mode))
   {
   case 0 :
      if( ! attributes)
         return( YES);
      
   case EEXIST :
      if( attributes)
         return( [self setAttributes:attributes
                        ofItemAtPath:path
                               error:error]);
      return( YES);

   case ENOENT:
      if( ! createIntermediates)
      {
         MulleObjCSetCurrentErrnoError( error);
         return( NO);
      }
      break;
      
   case -1 :
      MulleObjCSetCurrentErrnoError( error);
      return( NO);
   }
   
   // does not exist, create it
   
   subComponents = [NSMutableArray array];

   components = [path pathComponents];
   n          = [components count];
   for( i = 0; i < n; i++)
   {
      [subComponents addObject:[components objectAtIndex:i]];
      subpath = [subComponents pathWithComponents:subComponents];
      
      if( ! [self createDirectoryAtPath:subpath
            withIntermediateDirectories:NO
                             attributes:attributes
                                  error:error])
         return( NO);
   }
   
   if( attributes)
      return( [self setAttributes:attributes
                     ofItemAtPath:path
                            error:error]);
   return( YES);
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


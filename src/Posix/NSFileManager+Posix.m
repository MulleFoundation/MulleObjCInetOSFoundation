//
//  NSFileManager+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "dependencies.h"

#import <MulleObjCOSBaseFoundation/private/NSFileManager-Private.h>
#import "MulleObjCPOSIXError.h"

// std-c and dependencies
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <float.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>


@implementation NSFileManager (Posix)

- (BOOL) changeCurrentDirectoryPath:(NSString *) path
{
   char   *c_string;

   c_string = [path fileSystemRepresentation];
   if( ! c_string)
      return( NO);

   if( chdir( c_string))
   {
      MulleObjCPOSIXSetCurrentErrnoError( NULL);
      return( NO);
   }

   return( YES);
}


- (NSString *) currentDirectoryPath
{
   char      *c_string;
   auto char  buf[ PATH_MAX];

   c_string = getcwd( buf, sizeof( buf));
   if( ! c_string)
   {
      MulleObjCPOSIXSetCurrentErrnoError( NULL);
      return( nil);
   }

   return( [self stringWithFileSystemRepresentation:c_string
                                             length:strlen( c_string)]);
}


- (int) _isValidDirectoryContentsFilenameAsCString:(char *) s
{
   int  c;

   if( ! s || ! *s)
      return( _MulleObjCFilenameIsNoFile);
   if( *s != '.')
      return( _MulleObjCFilenameIsNormal);
   c = s[ 1];
   if( ! c)
      return( _MulleObjCFilenameIsDot);
   if( c == '_')
      return( _MulleObjCFilenameIsSystem);
   if( c == '.' && ! s[ 2])
      return( _MulleObjCFilenameIsDotDot);
   return( _MulleObjCFilenameIsHidden);
}

#pragma mark - chmod

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

   if( ! [attributes count])
      return( YES);

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
         MulleObjCPOSIXSetCurrentErrnoError( error);
         return( NO);
      }
   }

   nr = [attributes objectForKey:NSFilePosixPermissions];
   if( nr)
   {
      mode = (mode_t) [nr unsignedIntValue];
      if( chmod( s, mode))
      {
         MulleObjCPOSIXSetCurrentErrnoError( error);
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
         MulleObjCPOSIXSetCurrentErrnoError( error);
         return( NO);
      }
   }

   return( YES);
}

#pragma mark - mkdir

- (int) _createDirectoryAtPath:(NSString *) path
                     attributes:(NSDictionary *) attributes
{
   mode_t   mode;
   char     *s;

   if( ! attributes)
      mode = umask( 3777);
   else
      mode = (mode_t) [[attributes objectForKey:NSFilePosixPermissions] unsignedIntValue];

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

   // first try simple case
   switch( [self _createDirectoryAtPath:path
                             attributes:attributes])
   {
      case 0 :
         if( ! attributes)
            return( 0);

         return( [self setAttributes:attributes
                        ofItemAtPath:path
                               error:error]);
      case ENOENT:
         if( createIntermediates)
            break;

      default :
         MulleObjCPOSIXSetCurrentErrnoError( error);
         return( NO);
   }

   // does not exist, create it

   subComponents = [NSMutableArray array];

   components = [path pathComponents];
   n          = [components count];
   for( i = 0; i < n; i++)
   {
      [subComponents addObject:[components objectAtIndex:i]];
      subpath = [NSString pathWithComponents:subComponents];

      switch( [self _createDirectoryAtPath:subpath
                                attributes:attributes])
      {
         case EEXIST :
            break;

         case 0 :
            if( ! [self setAttributes:attributes
                         ofItemAtPath:path
                                error:error])
               return( NO);
            break;

         default :
            MulleObjCPOSIXSetCurrentErrnoError( error);
            return( NO);
      }
   }

   return( YES);
}


#pragma mark - stat

static int    stat_at_path( NSString *path, struct stat *c_info)
{
   char   *c_path;
   int    rval;

   c_path = [path fileSystemRepresentation];
   if( ! c_path)
      return( -1);

   rval = stat( c_path, c_info);
   if( rval)
      MulleObjCPOSIXSetCurrentErrnoError( NULL);
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


#pragma mark - directories


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

      switch( [self _isValidDirectoryContentsFilenameAsCString:s])
      {
         case _MulleObjCFilenameIsHidden : // spec, i think
         case _MulleObjCFilenameIsNormal : break;
         default             : continue;
      }

      filename = [NSString stringWithCString:s];
      [array addObject:filename];
   }
   closedir( dir);

   return( array);
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


- (struct timespec) _getCTimeFromStat:(struct stat *) stat
{
   struct timespec   timespec;

   timespec.tv_sec  = stat->st_ctime;
   timespec.tv_nsec = 0;
   return( timespec);
}


- (struct timespec) _getMTimeFromStat:(struct stat *) stat
{
   struct timespec   timespec;

   timespec.tv_sec  = stat->st_mtime;
   timespec.tv_nsec = 0;
   return( timespec);
}


- (NSDictionary *) fileSystemAttributesAtPath:(NSString *) path
{
   NSMutableDictionary  *dictionary;
   char                 *c_path;
   struct stat          c_info;
   NSString             *type;
   struct timespec      timespec;

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
   timespec = [self _getCTimeFromStat:&c_info];

   //   timespec.tv_nsec = c_info.st_ctimensec;
   set_date_key_value( dictionary, NSFileCreationDate, timespec);

   timespec = [self _getMTimeFromStat:&c_info];
   //   timespec.tv_nsec = c_info.st_mtimensec;
   set_date_key_value( dictionary, NSFileModificationDate, timespec);

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

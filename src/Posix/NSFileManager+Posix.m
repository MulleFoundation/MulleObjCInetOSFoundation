//
//  NSFileManager+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly

/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/


#define _XOPEN_SOURCE 700

#import "import-private.h"

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

   s     = [self fileSystemRepresentationWithPath:path];
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
            return( NO);
      }
   }

   nr = [attributes objectForKey:NSFilePosixPermissions];
   if( nr)
   {
      mode = (mode_t) [nr unsignedIntValue];
      if( chmod( s, mode))
      {
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
            return( NO);
      }
   }

   return( YES);
}


#pragma mark - ln -s

- (BOOL) createSymbolicLinkAtPath:(NSString *) path
              withDestinationPath:(NSString *) otherpath
                            error:(NSError **) error
{
   abort();  // not yet coded
}


#pragma mark - mkdir

- (int) _createDirectoryAtPath:(NSString *) path
                     attributes:(NSDictionary *) attributes
{
   mode_t   mode;
   char     *s;

   if( ! attributes)
      mode = 0777;
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
            return( YES);

         /* remove NSFilePosixPermissions since its been done already */
         attributes = [attributes mulleDictionaryByRemovingObjectForKey:NSFilePosixPermissions];
         return( [self setAttributes:attributes
                        ofItemAtPath:path
                               error:error]);
      case ENOENT:
         if( createIntermediates)
            break;

      default :
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
   {
      errno = EINVAL;
      return( -1);
   }

   rval = stat( c_path, c_info);
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

   /* directories are not considered executable or ? */
   if( c_info.st_mode & S_IFDIR)
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

#pragma clang diagnostic ignored  "-Wparentheses"

- (NSArray *) directoryContentsAtPath:(NSString *) path
{
   DIR              *dir;
   NSMutableArray   *array;
   NSString         *filename;
   struct dirent    *entry;
   char             *s;

   dir = opendir( [path fileSystemRepresentation]);
   if( ! dir)
   {
      return( nil);
   }

   array = [NSMutableArray array];
   errno = 0;
   while( entry = readdir( dir))
   {
      s = entry->d_name;

      switch( [self _isValidDirectoryContentsFilenameAsCString:s])
      {
         case _MulleObjCFilenameIsHidden : // spec, i think
         case _MulleObjCFilenameIsNormal : break;
         default                         : continue;
      }

      filename = [NSString stringWithCString:s];
      [array addObject:filename];
   }
   if( errno)

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
   {
      return( NO);
   }
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
   {
      return( nil);
   }

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

- (BOOL) _removeFileItemAtPath:(NSString *) path
{
   char  *c_path;

   // could possibly try to chmod it ?
   c_path = [path fileSystemRepresentation];
   if( unlink( c_path))
   {
      return( NO);
   }
   return( YES);
}


- (BOOL) _removeEmptyDirectoryItemAtPath:(NSString *) path
{
   char   *c_path;

   c_path = [path fileSystemRepresentation];
   if( rmdir( c_path))
   {
      return( NO);
   }
   return( YES);
}



- (NSString *) destinationOfSymbolicLinkAtPath:(NSString *) path
                                         error:(NSError **) error
{
   char      buf[ PATH_MAX + 1];  // might be too large for stack ?
   ssize_t   length;

   length = readlink( [path fileSystemRepresentation], buf, PATH_MAX);
   if( length == -1)
   {
      if( error)
         *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                      code:errno
                                  userInfo:nil];
      return( nil);
   }
   buf[ length] = 0;
   return( [self stringWithFileSystemRepresentation:buf
                                             length:length + 1]);
}


#pragma mark - Cocotron


#define FOUNDATION_FILE_MODE (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
#define FOUNDATION_DIR_MODE  (S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH)


static inline void   NSRaiseException( NSString *name,
                                       id obj,
                                       SEL sel,
                                       NSString *format, ...)
{
   mulle_vararg_list   arguments;
   NSString            *reason;

   mulle_vararg_start( arguments, format);
   reason = [NSString stringWithFormat:format
                        mulleVarargList:arguments]

   mulle_vararg_end( arguments);


   [NSException raise:name
               format:@"%@ %@: %@", obj, NSStringFromSelector( sel), reason];
}


/* Cocotron code */

-(BOOL)_isDirectory:(NSString *)path {
    struct stat buf;

    if(lstat([path fileSystemRepresentation],&buf)<0)
        return NO;

    if (buf.st_mode & S_IFDIR && !(buf.st_mode & S_IFLNK))
        return YES;

    return NO;
}

-(BOOL)_errorHandler:handler src:(NSString *)src dest:(NSString *)dest operation:(NSString *)op {
    if ([handler respondsToSelector:@selector(fileManager:shouldProceedAfterError:)]) {
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            src, @"Path",
            [NSString stringWithFormat:@"%@: %s", op, strerror(errno)], @"Error",
            dest, @"ToPath",
            nil];

        if ([handler fileManager:self shouldProceedAfterError:errorInfo])
            return YES;
    }

    return NO;
}


-(BOOL)movePath:(NSString *)src toPath:(NSString *)dest handler:handler {
    NSError *error = nil;

    if ([handler respondsToSelector:@selector(fileManager:willProcessPath:)])
        [handler fileManager:self willProcessPath:src];

    if ([self moveItemAtPath:src toPath:dest error:&error] == NO && handler != nil) {
        [self _errorHandler:handler src:src dest:dest operation:[error description]];
        return NO;
    }

    return YES;
}

- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error
{

    /*
     It's not this easy...
     return rename([src fileSystemRepresentation],[dest fileSystemRepresentation])?NO:YES;
     */

    BOOL isDirectory;

//TODO fill error

    if ([self fileExistsAtPath:srcPath isDirectory:&isDirectory] == NO)
        return NO;
    if ([self fileExistsAtPath:dstPath isDirectory:&isDirectory] == YES)
        return NO;

    if ([self copyPath:srcPath toPath:dstPath handler:nil] == NO) {
        [self removeFileAtPath:dstPath handler:nil];
        return NO;
    }

    // not much we can do if this fails
    [self removeFileAtPath:srcPath handler:nil];

    return YES;
}

-(BOOL)copyPath:(NSString *)src toPath:(NSString *)dest handler:handler {
    NSError *error = nil;
    if ([self copyItemAtPath:src toPath:dest error:&error] == NO && handler != nil) {
        [self _errorHandler:handler src:src dest:dest operation:[error description]];
        return NO;
    }

    return YES;
}

-(BOOL)copyItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error
{
    BOOL isDirectory;

    if(![self fileExistsAtPath:fromPath isDirectory:&isDirectory]) {
        if (error != NULL) {
            //TODO set error
        }
        return NO;
    }

    if (!isDirectory){
        int r, w;
        char buf[4096];
        size_t count;

        if ((w = open([toPath fileSystemRepresentation], O_WRONLY|O_CREAT, FOUNDATION_FILE_MODE)) == -1) {
            if (error != NULL) {
                //TODO set error
            }
            return NO;
        }
        if ((r = open([fromPath fileSystemRepresentation], O_RDONLY)) == -1) {
            if (error != NULL) {
                //TODO set error
            }
            close(w);
            return NO;

        }

        while ((count = read(r, &buf, sizeof(buf))) > 0) {
            if (count == -1)
                break;

            if (write(w, &buf, count) != count) {
                count = -1;
                break;
            }
        }

        close(w);
        close(r);

        if (count == -1) {
            if (error != NULL) {
                //TODO set error
            }
            return NO;
        }
        else
            return YES;
    }
    else {
        NSArray *files;
        NSInteger      i,count;

        if (mkdir([toPath fileSystemRepresentation], FOUNDATION_DIR_MODE) != 0) {
            if (error != NULL) {
                //TODO set error
            }
            return NO;
        }

        //if (chdir([dest fileSystemRepresentation]) != 0)
        //    return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: chdir(subdir)"];

        files = [self directoryContentsAtPath:fromPath];
        count = [files count];

        for(i=0;i<count;i++){
            NSString *name=[files objectAtIndex:i];
            NSString *subsrc, *subdst;

            if ([name isEqualToString:@"."] || [name isEqualToString:@".."])
                continue;

            subsrc=[fromPath stringByAppendingPathComponent:name];
            subdst=[toPath stringByAppendingPathComponent:name];

            if([self copyItemAtPath:subsrc toPath:subdst error:error] == NO) {
                if (error != NULL) {
                    //TODO set error
                }
                return NO;
            }
        }

        //if (chdir("..") != 0)
        //    return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: chdir(..)"];
    }

    return YES;

}


@end

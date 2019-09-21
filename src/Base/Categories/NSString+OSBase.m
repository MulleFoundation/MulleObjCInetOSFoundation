/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+PosixPathHandling.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSString+OSBase.h"

// other files in this library
#import "NSFileManager.h"
#import "NSPathUtilities.h"
#import "NSData+OSBase.h"

// std-c and dependencies

#pragma clang diagnostic ignored "-Wparentheses"


@implementation NSString( OSBase)

- (BOOL) isAbsolutePath
{
   return( [self hasPrefix:NSFilePathComponentSeparator]);
}


// use string subclass that keeps components separate
+ (instancetype) pathWithComponents:(NSArray *) components
{
   return( [components componentsJoinedByString:NSFilePathComponentSeparator]);
}

///
// This method can make the following changes in the provided string:
//
// Expand an initial tilde expression using stringByExpandingTildeInPath.
// Reduce empty components and references to the current directory (that
// is, the sequences “//” and “/./”) to single path separators.
// In absolute paths only, resolve references to the parent directory
// (that is, the component “..”) to the real parent directory if possible
// using stringByResolvingSymlinksInPath, which consults the file system
// to resolve each potential symbolic link.
// In relative paths, because symbolic links can’t be resolved, references
// to the parent directory are left in place.
//
// Remove an initial component of “/private” from the path if the result
// still indicates an existing file or directory (checked by consulting
// the file system).
//
- (NSString *) initWithPathComponents:(NSArray *) components
{
   NSString  *s;

   s = [components componentsJoinedByString:NSFilePathComponentSeparator];
   [self autorelease];
   [s retain];

   return( s);
}


- (NSArray *) pathComponents
{
   return( [self componentsSeparatedByString:NSFilePathComponentSeparator]);
}


static NSMutableArray  *arrayWithComponents( NSArray *components, NSRange range, BOOL includeFirst)
{
   NSMutableArray   *array;

   array = [NSMutableArray array];
   if( includeFirst && range.location != 0)
      [array addObject:[components objectAtIndex:0]];
   [array addObjectsFromArray:[components subarrayWithRange:range]];
   return( array);
}


- (NSString *) _stringBySimplifyingPath
{
   enum
   {
      isUnknown,
      isAbsolute,
      isDot,
      isDotDot
   } pathtype;
   NSArray      *components;
   id           result;
   NSString     *s;
   NSString     *prev;
   NSUInteger   i, n;
   BOOL         skipping;
   NSUInteger   len;
   NSUInteger   start;

   //
   // if this is nil, path has no @"/" anywhere
   //
   components = [self _componentsSeparatedByString:NSFilePathComponentSeparator];
   if( ! components)
      return( self);

   pathtype = isUnknown;
   skipping = YES;
   result   = nil;
   start    = 0;

   n = [components count];
   for( i = 0; i < n; i++)
   {
      s   = [components objectAtIndex:i];
      len = [s length];

         // if path starts with '/' or '.' we can collapse '..'
      if( ! len || [@"." isEqualToString:s])
      {
         if( ! i)
            pathtype = ! len ? isAbsolute : isDot;

         // skip over '//' and '/./'
         if( skipping)
            ++start;
         continue;
      }

      // convert "/foo/../" to "foo"
      // though symlinks should be resolved now

      if( [@".." isEqualToString:s])
      {
         if( ! i)
         {
            pathtype = isDotDot;
            ++start;    // still update this for later output
            skipping = NO;
            continue;
         }

         if( skipping && isAbsolute)
         {
            if( skipping)
               ++start;    // collapse /.. to /
            continue;
         }

         if( ! result)
            result = arrayWithComponents( components, NSMakeRange( start, i - start), YES);

         prev = [result lastObject];
         if( ! [@".." isEqualToString:prev])
         {
            if( ! [prev length])
               continue;

            [result removeLastObject];
            if( ! [result count])
            {
               result = nil;
               start  = i;
            }
            continue;
         }
      }

      // keep adding to nil, if there was nothing to collapse
      if( ! result && start)
         result = arrayWithComponents( components, NSMakeRange( start, i - start), YES);
      [result addObject:s];
      skipping = NO;
   }

   if( start == i)
   {
      switch( pathtype)
      {
         case isAbsolute : return( NSFilePathComponentSeparator);
         case isDot      : return( @".");
         case isDotDot   : return( @"..");
         default         : break;
      }
   }
   if( ! result && ! start)
      return( self);

   if( ! result)
      result = arrayWithComponents( components, NSMakeRange( start, i - start), YES);

   // remove trailing '/' if any
   len = [result count];
   while( len)
   {
      s = [result lastObject];
      if( [s length] && ! [s isEqualToString:@"."])
         break;
      [result removeLastObject];
      --len;
   }

   if( ! len)
   {
      switch( pathtype)
      {
         case isAbsolute : return( NSFilePathComponentSeparator);
         case isDot      : return( @".");
         case isDotDot   : return( @"..");
         default         : break;
      }
   }

   return( [result componentsJoinedByString:NSFilePathComponentSeparator]);
}


//
// this is not what darwin will do (in a category)
//
- (NSString *) _stringByRemovingPrivatePrefix
{
   return( self);
}


- (NSString *) stringByStandardizingPath
{
   NSString        *path;

   path = self;
//   path = [self stringByExpandingTildeInPath];  // already done by symlinks
   path = [path stringByResolvingSymlinksInPath];
   path = [path _stringBySimplifyingPath];

   //
   // that's what MacOS does, don't know why.
   // we only do this in Darwin
   path = [path _stringByRemovingPrivatePrefix];

   return( path);
}


// resist the urge, to standardize
//   [@"a" stringByAppendingPathComponent:@"b"]     ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"b"]    ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"b"]    ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"b"]   ->  /a/b
//   [@"a" stringByAppendingPathComponent:@"b/"]    ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"b/"]   ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"b/"]   ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"b/"]  ->  /a/b
//   [@"a" stringByAppendingPathComponent:@"/b"]    ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"/b"]   ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"/b"]   ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"/b"]  ->  /a/b
//   [@"a" stringByAppendingPathComponent:@"/b/"]   ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"/b/"]  ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"/b/"]  ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"/b/"] ->  /a/b
//
- (NSString *) stringByAppendingPathComponent:(NSString *) other
{
   BOOL        hasSuffix;
   BOOL        otherHasPrefix;
   BOOL        otherHasSuffix;
   NSUInteger  len;
   NSUInteger  other_len;

   len       = [self length];
   hasSuffix = [self hasSuffix:NSFilePathComponentSeparator];

   other_len      = [other length];
   otherHasSuffix = [other hasSuffix:NSFilePathComponentSeparator];
   if( otherHasSuffix)
   {
      --other_len;
      other = [other substringWithRange:NSMakeRange( 0, other_len)];
   }

   otherHasPrefix = [other hasPrefix:NSFilePathComponentSeparator];

   if( ! hasSuffix && ! other_len)
      return( self);

   if( ! len)  // "" + "b" -> "b"
      return( other);

   //    S  P
   //  ---+----
   //    0  0     add '/'
   //    0  1     just concat
   //    1  0     just concat
   //    1  1     remove '/'

   if( ! (otherHasPrefix ^ hasSuffix))
   {
      if( hasSuffix) // case 1 1
      {
         if( other_len == 1)
            return( [self substringWithRange:NSMakeRange( 0, len - 1)]);
         other = [other substringFromIndex:1];
      }
      else          // case 0 0
         other = [NSFilePathComponentSeparator stringByAppendingString:other];
   }

   return( [self stringByAppendingString:other]);
}


// resist the urge, to standardize
- (NSString *) stringByAppendingPathExtension:(NSString *) extension
{
   NSString   *s;

   s = self;
   if( [s hasSuffix:@"/"])
      s = [self substringToIndex:[self length] - 1];

   return( [s stringByAppendingFormat:@"%@%@", NSFilePathExtensionSeparator, extension]);
}


//
// this only works if ~ is in front
// see: https://developer.apple.com/documentation/foundation/nsstring/1407716-stringbyexpandingtildeinpath?language=objc
//
- (NSString *) stringByExpandingTildeInPath
{
   id        components;
   NSString  *first;
   NSString  *home;

   if( ! [self hasPrefix:@"~"])
      return( self);

   components = [self pathComponents];
   first      = [components objectAtIndex:0];
   if( [first length] == 1)
      home = NSHomeDirectory();
   else
      home = NSHomeDirectoryForUser( [first substringFromIndex:1]);
   if( ! home)
      return( self);

   components = [NSMutableArray arrayWithArray:components];
   [components replaceObjectAtIndex:0
                         withObject:home];
   return( [NSString pathWithComponents:components]);
}


- (NSString *) stringByResolvingSymlinksInPath
{
   NSFileManager     *manager;
   NSArray           *components;
   NSMutableString   *s;
   NSString          *path;
   NSString          *component;
   NSString          *expanded;
   NSString          *best;
   NSUInteger        len;

   path = [self stringByExpandingTildeInPath];
   if( ! [path isAbsolutePath])
      return( path);

   manager    = [NSFileManager defaultManager];
   components = [path componentsSeparatedByString:NSFilePathComponentSeparator];
   s          = [NSMutableString string];
   for( component in components)
   {
      len = [component length];
      if( ! len)
         continue;
      [s appendString:NSFilePathComponentSeparator];
      [s appendString:component];

      best = s;
      while( expanded = [manager pathContentOfSymbolicLinkAtPath:best])
         best = expanded;
      if( best == s)
         continue;
      [s setString:best];
   }
   if( ! [s length])
      return( NSFilePathComponentSeparator);
   return( s);
}


/*
  * /tmp/scratch.tiff -> scratch.tiff
  * /tmp/scratch”     -> scratch
  * /tmp/”            -> tmp
  * scratch           -> scratch
  * /                 -> /
*/
static NSRange  getLastPathComponentRange( NSString *self)
{
   NSRange      range;
   NSUInteger   len;

   len   = [self length];
   range = [self rangeOfString:NSFilePathComponentSeparator
                       options:NSLiteralSearch|NSBackwardsSearch];
   // if found trailing '/', skip it (but only once)
   if( range.location == len - 1)
      range = [self rangeOfString:NSFilePathComponentSeparator
                          options:NSBackwardsSearch
                            range:NSMakeRange( 0, len - 1)];

   if( range.location == 0 || range.length == 0) // is root or just the file
      return( NSMakeRange( 0, len));

   // otherwise range it toge
   range.location++;   // skip over '/'
   return( NSMakeRange( range.location, len - range.location));
}


static NSRange  getPathExtensionRange( NSString *self)
{
   NSRange   range1;
   NSRange   range2;

   // first get lastPathComponent range
   range1 = getLastPathComponentRange( self);
   if( range1.length == 0)
      return( range1);

   range2 = [self rangeOfString:NSFilePathExtensionSeparator
                        options:NSBackwardsSearch
                          range:range1];
   // /.tiff is not an extension!
   if( ! range2.length || range2.location <= range1.location)
      return( NSMakeRange( NSNotFound, 0));

   ++range2.location;
   return( NSMakeRange( range2.location, (range1.location + range1.length) - range2.location));
}


- (NSString *) lastPathComponent
{
   NSRange   range;

   range = getLastPathComponentRange( self);
   if( ! range.length)
      return( self);
   return( [self substringFromIndex:range.location]);
}


- (NSString *) stringByDeletingLastPathComponent
{
   NSRange   range;

   range = getLastPathComponentRange( self);
   if( ! range.length)
      return( self);

   // skip over '/' if available
   if( range.location)
      --range.location;
   return( [self substringToIndex:range.location]);
}


- (NSString *) pathExtension
{
   NSRange   range;

   range = getPathExtensionRange( self);
   if( ! range.length)
      return( @"");
   return( [self substringWithRange:range]);
}


- (NSString *) stringByDeletingPathExtension
{
   NSRange   range;

   range = getPathExtensionRange( self);
   if( ! range.length)
      return( self);

   NSCParameterAssert( range.location);
   // also snip off "dot"
   return( [self substringToIndex:range.location - 1]);
}


//
// TODO: need to convert to proper characterset
//
- (char *) fileSystemRepresentation
{
   return( [[NSFileManager sharedInstance] fileSystemRepresentationWithPath:self]);
}


// this is not as fast as you may think :)
- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max
{
   char     *s;
   size_t   len;

   s = [[NSFileManager sharedInstance] fileSystemRepresentationWithPath:self];
   if( ! s)
      return( NO);
   len = strlen( s);
   if( len > max)
      return( NO);

   memcpy( buf, s, len);
   return( YES);
}


+ (instancetype) stringWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   NSData             *data;
   uint8_t            *bytes;
   NSUInteger         length;
   NSStringEncoding   encoding;
   mulle_utf16_t      c16;
   mulle_utf32_t      c32;

   data = [NSData dataWithContentsOfFile:path];
   if( ! data)
   {
      [self release];
      return( nil);
   }

   length   = [data length];
   encoding = NSUTF8StringEncoding;

   do
   {
      if( ! length)
         break;
      // if length is odd, it must be 8 bit
      if( length & 0x1)
         break;

      bytes = [data bytes];
      c16   = (mulle_utf16_t) ((bytes[ 0] << 8) | bytes[ 1]);
      if( mulle_utf16_get_bomcharacter() == c16)
      {
         encoding = NSUTF16BigEndianStringEncoding;
         break;
      }

      c16   = (mulle_utf16_t) ((bytes[ 1] << 8) | bytes[ 0]);
      if( mulle_utf16_get_bomcharacter() == c16)
      {
         encoding = NSUTF16LittleEndianStringEncoding;
         break;
      }

      if( length < 4)
         break;

      c32 = (mulle_utf32_t) ((bytes[ 0] << 24) |
                             (bytes[ 1] << 16) |
                             (bytes[ 2] << 8) |
                             bytes[ 3]);
      if( mulle_utf32_get_bomcharacter() == c32)
      {
         encoding = NSUTF32BigEndianStringEncoding;
         break;
      }

      c32 = (mulle_utf32_t) ((bytes[ 3] << 24) |
                             (bytes[ 2] << 16) |
                             (bytes[ 1] << 8) |
                             bytes[ 0]);
      if( mulle_utf32_get_bomcharacter() == c32)
      {
         encoding = NSUTF32LittleEndianStringEncoding;
         break;
      }
   }
   while( 0);

   return( [self initWithData:data
                     encoding:encoding]);

}

- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSData  *data;

   data = [self dataUsingEncoding:NSUTF8StringEncoding];
   assert( data);
   return( [data writeToFile:path
                  atomically:flag]);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
            encoding:(NSStringEncoding) encoding
               error:(NSError **) error
{
   NSData  *data;

   data = [self dataUsingEncoding:encoding];
   return( [data writeToFile:path
                  atomically:flag
                       error:error]);
}


@end

/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import "NSString+PosixPathHandling.h"

// other files in this library
#import "NSFileManager.h"
#import "NSPathUtilities.h"

// std-c and dependencies


@implementation NSString( PosixPathHandling)

NSString  *NSFilePathComponentSeparator = @"/";
NSString  *NSFilePathExtensionSeparator = @".";


- (BOOL) isAbsolutePath
{
   return( [self hasPrefix:NSFilePathComponentSeparator]);
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


- (NSString *) _stringBySimplifyingPath
{
   NSArray         *components;
   NSMutableArray  *result;
   NSString        *s;
   NSUInteger      i, n;
   BOOL            isAbsolute;
   
   // if this is nil, path has no @"/" anywhere
   // 
   components = [self _componentsSeparatedByString:NSFilePathComponentSeparator];
   if( ! components)
      return( self);
   
   isAbsolute = NO;
   result     = nil;
   
   n = [components count];   
   for( i = 0; i < n; i++)
   {
      s = [components objectAtIndex:i];
      if( ! [s length] || [@"." isEqualToString:s])
      {
         if( ! i)
         {
            isAbsolute = YES;
            continue;
         }
         if( ! result)
            result = [NSMutableArray arrayWithArray:components
                                              range:NSMakeRange( 0, i)];
         continue;
      }
      if( isAbsolute)
      {
         if( [@".." isEqualToString:s])
         {
            if( ! result)
               result = [NSMutableArray arrayWithArray:components
                                                 range:NSMakeRange( 0, i ? i - 1 : 0)];
            else
               [result removeLastObject];
            continue;
         }
      }
      [result addObject:s];
   }
   
   if( result)
      return( [result componentsJoinedByString:NSFilePathComponentSeparator]);

   return( self);
}   

//
// this is not like what MacOSX does, which does much more
// 

- (NSString *) _stringByRemovingPrivatePrefix
{
   return( self);
}


- (NSString *) stringByStandardizingPath
{
   NSString        *path;
   
//   path = [self stringByExpandingTildeInPath];  // already done by symlinks
   path = [self stringByResolvingSymlinksInPath];
   path = [self _stringBySimplifyingPath];

   //
   // that's what MacOS does, don't know why.
   // we only do this in Darwin
   path = [self _stringByRemovingPrivatePrefix];
         
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


- (NSString *) stringByExpandingTildeInPath
{
   NSArray   *components;
   NSString  *s;
   
   components = [self _componentsSeparatedByString:@"~"];
   if( ! components)
      return( self);
      
   s = [components componentsJoinedByString:NSHomeDirectory()];
   return( s);
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
   NSEnumerator      *rover;
   NSUInteger        len;
   
   path = [self stringByExpandingTildeInPath];
   if( ! [path isAbsolutePath])
      return( path);
      
   manager    = [NSFileManager defaultManager];
   components = [self componentsSeparatedByString:NSFilePathComponentSeparator];
   s          = [NSMutableString string];
   rover      = [components objectEnumerator];
   while( component = [rover nextObject])
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
      return( nil);
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
@end

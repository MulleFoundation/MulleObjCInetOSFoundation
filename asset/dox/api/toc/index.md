# MulleObjCInetOSFoundation Library Documentation for AI
<!-- Keywords: networking, filesystem, url, host, data, file -->

## 1. Introduction & Purpose

MulleObjCInetOSFoundation is the OS-specific bridge layer that connects the
internet-facing classes of `MulleObjCInetFoundation` (NSHost, NSURL) to the
operating system facilities of `MulleObjCOSFoundation` (files, NSData).

It solves the problem of treating `file://` URLs uniformly with network URLs:
an AI can create NSURL objects from filesystem paths, recover the native
filesystem representation of a URL path, load file contents as NSData through
a URL, and write NSData back through a URL. It also provides an OS-level
`currentHost` implementation.

It is implemented entirely as mulle-objc *category extensions* (no new classes
are introduced): `NSURL( Filesystem)`, `NSData( NSURL)` and `NSHost( OS)`.

## 2. Key Concepts & Design Philosophy

- **Category extension over subclassing:** The library only adds methods to
  existing base classes via categories, so code written against NSURL/NSData/NSHost
  works unchanged and the added methods appear as if they were always there.
- **File-URL as the filesystem gateway:** All OS file operations go through
  `file://` URLs. The implementation checks `[url isFileURL]` before dispatching
  to the filesystem; non-file URLs either return `nil`/`NO`.
- **Delegation, not duplication:** The extension methods delegate to the
  equivalent path-based OS methods (e.g. `dataWithContentsOfFile:`,
  `writeToFile:`, `initWithScheme:`) rather than re-implementing I/O.
- **`isDirectory` hint is currently a no-op:** The flag is accepted for source
  compatibility but the current implementation discards it, and never
  appends a trailing `/`.
- **Convenience is preferred:** `+` factory methods (with `autorelease`) are
  provided; instances should not be manually `alloc`/`init`'d by callers.

## 3. Core API & Data Structures

### 3.1. `MulleObjCInetOSFoundation.h`

Umbrella public header. Introduces the version API and re-exports the three
category extension headers.

#### Version macro and functions

- `MULLE_OBJC_INET_OS_FOUNDATION_VERSION` — version packed as
  `(major << 20) | (minor << 8) | patch`. Current value encodes `0.20.10`.
- `MulleObjCInetOSFoundation_get_version( void)` → `uint32_t`
- `MulleObjCInetOSFoundation_get_version_major( void)` → `unsigned int`
- `MulleObjCInetOSFoundation_get_version_minor( void)` → `unsigned int`
- `MulleObjCInetOSFoundation_get_version_patch( void)` → `unsigned int`

### 3.2. `NSURL+Filesystem.h`

Extends `NSURL` with filesystem conversion and `file://` URL construction.

#### Global constant

- `NSURLFileScheme` — `NSString *` global holding the string `"file"`. Use as
  the default scheme for filesystem URLs.

#### Filesystem representation

- `- (char *) fileSystemRepresentation;` — returns the URL's path in the
  native filesystem encoding (as a C string).
- `- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max;` — writes the
  filesystem representation into `buf` up to `max` bytes; returns `YES` on success.

#### File URL construction

- `- (instancetype) initFileURLWithPath:(NSString *) path;` — instance
  initializer: builds a URL with scheme `NSURLFileScheme`, no host, given `path`.
- `+ (instancetype) fileURLWithPath:(NSString *) path;` — autoreleased factory;
  preferred form. Returns `[self initWithScheme:NSURLFileScheme host:nil path:path]`.
- `- (instancetype) initFileURLWithPath:(NSString *) path
                         isDirectory:(BOOL) isDirectory;` — same as above;
  `isDirectory` is currently ignored (`MULLE_C_UNUSED`).
- `+ (instancetype) fileURLWithPath:(NSString *) path
                     isDirectory:(BOOL) isDirectory;` — autoreleased factory
  variant with the directory hint.
- `+ (instancetype) fileURLWithPathComponents:(NSArray *)components;` —
  builds the path via `[NSString pathWithComponents:components]` and then
  creates the file URL. Use for platform-portable path building.

### 3.3. `NSData+NSURL.h`

Extends `NSData` to read/write data through URLs. Only `file://` URLs are
supported; non-file URLs yield `nil` (read) or `NO` (write).

- `+ (instancetype) dataWithContentsOfURL:(NSURL *) url
                               options:(NSDataReadingOptions) options
                                 error:(NSError **) error;` — reads the
  contents of a file URL into a new NSData. `options` and `error` are accepted
  for API compatibility but are currently unused: `options` is ignored and
  `error` is set to `nil`. Dispatches to `dataWithContentsOfFile:`.
- `+ (instancetype) dataWithContentsOfURL:(NSURL *) path;` — simplified factory
  without options/error.
- `- (instancetype) initWithContentsOfURL:(NSURL *) path;` — instance
  initializer variant, dispatches to `initWithContentsOfFile:`.
- `- (BOOL) writeToURL:(NSURL *) path
         atomically:(BOOL) flag;` — writes the NSData contents to a file URL;
  `flag` controls atomic write; dispatches to `writeToFile:`. Returns `NO` for
  non-file URLs.

Note: `NSDataReadingOptions` is a `typedef NSUInteger` defined by the
`MulleObjCOSFoundation` dependency (values include `NSDataReadingMappedIfSafe`,
`NSDataReadingUncached`, `NSDataReadingMappedAlways`).

### 3.4. `NSHost+OS.h`

Extends `NSHost` with an OS-level current-host implementation.

- `+ (instancetype) currentHost;` — returns an autoreleased NSHost built with
  `initWithNames:addresses:`. The current implementation hardcodes the loopback
  host: name `"localhost"`, addresses `"127.0.0.1"` and `"::1"` (IPv6 loopback).
  This overrides/supplies the base `NSHost( Future) currentHost`.

### 3.5. `MulleObjCDeps+MulleObjCInetOSFoundation.h`

Declares the runtime dependency provider, needed so libraries depending on this
one can register their load order in their `MulleObjCDeps` loader class.

- `+ (struct _mulle_objc_dependency *) dependencies;` — returns the list of
  this library's runtime object dependencies.

## 4. Performance Characteristics

- **No data structures of its own:** The library is a thin delegation layer, so
  performance is bounded by the base classes and underlying OS calls.
- **File URL creation:** O(n) in path length (string copying / percent-encoding
  done by base NSURL `initWithScheme:`); `fileSystemRepresentation` is O(n) in
  path length.
- **`dataWithContentsOfURL`:** O(n) disk I/O for file URLs, plus mapping/caching
  behavior inherited from `dataWithContentsOfFile:` giving the file size in memory.
- **`writeToURL`:** O(n) write; O(file size) extra temporary space when
  `atomically:YES`.
- **`currentHost`:** O(1), no network/DNS access (statically built loopback host).
- **Thread-safety:** No mutable global state besides the `NSURLFileScheme`
  global string (read-only). Category instances are plain objects; thread-safety
  follows the base NSData/NSURL/NSHost classes.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Prefer `+` factories over `init`:** Use `fileURLWithPath:`,
  `fileURLWithPathComponents:`, `dataWithContentsOfURL:` — they return
  autoreleased instances ready for use. Never call `-release` yourself outside
  `-dealloc`; the `+` methods already `autorelease`.
- **Always create file URLs for filesystem work:** The OS methods dispatch only
  when `[url isFileURL]` is true; otherwise you silently get `nil`/`NO`.
- **Use `fileURLWithPathComponents:` for portable paths** instead of
  hard-coding `/` or `\` separators; it converts via `pathWithComponents:` and
  handles the platform, though note it is not a filesystem existence check.
- **Use `getFileSystemRepresentation:maxLength:` when a caller-provided buffer
  is required** (Windows paths are best obtained through the native encoding
  this returns).
- **Set `atomically:YES` when writing files you must not corrupt on failure.**

### Common Pitfalls

- **A URL is not a path:** Do not pass raw filesystem paths to URL-parameter
  methods and expect them to be interpreted as paths. Conversely, use URL
  methods only on `file://` URLs.
- **`dataWithContentsOfURL` returns `nil` for non-file URLs** — always check for
  `nil` if the input URL may be from an untrusted source.
- **`options`/`error` are currently decorative:** The `dataWithContentsOfURL`
  implementation ignores `options` and unconditionally clears `error`. Do not
  rely on option semantics or on `error` being populated by *this* method.
- **`isDirectory:` is ignored for now:** Do not depend on trailing-slash or
  directory detection behavior; it exists for compatibility only.
- **Do not call `-release` on factory results:** `fileURLWithPath:` and friends
  autorelease; adding manual releases causes double releases.

### Idiomatic Usage

```objc
// Pattern 1: read a file through a URL
NSURL    *fileURL;
NSData   *data;

fileURL = [NSURL fileURLWithPath:@"/tmp/test.txt"];
data    = [NSData dataWithContentsOfURL:fileURL];

// Pattern 2: write a file through a URL
[data writeToURL:fileURL
      atomically:YES];

// Pattern 3: portable path construction
NSArray  *components;
NSURL    *docURL;

components = [NSArray arrayWithObjects:@"Users", @"nat", @"Documents", @"file.txt", nil];
docURL     = [NSURL fileURLWithPathComponents:components];
```

## 6. Integration Examples

### Example 1: Creating a File URL and Getting its Filesystem Representation

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int   main( void)
{
   char   buffer[ 1024];
   NSURL  *fileURL;

   fileURL = [NSURL fileURLWithPath:@"/tmp/test.txt"];

   if( [fileURL getFileSystemRepresentation:buffer
                             maxLength:1024])
   {
      printf( "native path: %s\n", buffer);
   }

   return( 0);
}
```

### Example 2: Reading Data from a File URL

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int   main( void)
{
   NSData  *data;
   NSURL   *fileURL;

   fileURL = [NSURL fileURLWithPath:@"/tmp/test.txt"];
   data    = [NSData dataWithContentsOfURL:fileURL];
   if( ! data)
   {
      fprintf( stderr, "failed to read %@\n", fileURL);
      return( 1);
   }

   return( 0);
}
```

### Example 3: Writing Data to a File URL Atomically

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int   main( void)
{
   BOOL     success;
   NSData   *data;
   NSURL    *fileURL;

   fileURL = [NSURL fileURLWithPath:@"/tmp/output.txt"];
   data    = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];

   success = [data writeToURL:fileURL
                      atomically:YES];
   if( ! success)
   {
      fprintf( stderr, "write failed\n");
      return( 1);
   }

   return( 0);
}
```

### Example 4: Building a Portable Path from Components

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int   main( void)
{
   NSArray  *components;
   NSURL    *docURL;

   components = [NSArray arrayWithObjects:@"tmp", @"logs", @"app.log", nil];
   docURL     = [NSURL fileURLWithPathComponents:components];

   printf( "scheme: %@\n", [docURL scheme]);
   printf( "path: %@\n",   [docURL path]);

   return( 0);
}
```

### Example 5: Current Host

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int   main( void)
{
   NSHost   *host;

   host = [NSHost currentHost];
   printf( "name: %@\n",    [host name]);
   printf( "address: %@\n", [host address]);

   return( 0);
}
```

## 7. Dependencies

- `MulleObjCInetFoundation` — base NSHost, NSURL classes and internet categories.
- `MulleObjCOSFoundation` — OS layer: NSData filesystem I/O, path handling,
  `NSDataReadingOptions` typedef.
- `mulle-objc-list` — lists mulle-objc runtime information contained in
  executables (no-header/no-import dependency).
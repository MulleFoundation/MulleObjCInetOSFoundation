# MulleObjCInetOSFoundation Library Documentation for AI

## 1. Introduction & Purpose

MulleObjCInetOSFoundation integrates networking and filesystem operations by adding OS-specific extensions to NSHost, NSURL, and NSData. Provides methods to work with file URLs, filesystem representations of URLs, and host lookups. Bridges the gap between internet primitives (NSHost, NSURL) and operating system file operations, enabling seamless URL-to-file and network-to-filesystem interactions.

## 2. Key Concepts & Design Philosophy

- **URL-to-Filesystem Bridge**: Convert URLs to filesystem paths and vice versa
- **File URL Support**: Create and manipulate file:// scheme URLs
- **URL Data Loading**: Read/write data using file and network URLs uniformly
- **Host Resolution**: Access system hostname and host information
- **Platform Abstraction**: Handle platform differences in file path representations
- **Seamless Integration**: Works with existing NSFileManager and NSData APIs

## 3. Core API & Data Structures

### NSURL (Filesystem) Category

#### File URL Creation

- `+ fileURLWithPath:(NSString *)path` → `instancetype`: Create file URL from path
- `+ fileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir` → `instancetype`: Create file URL (with directory hint)
- `+ fileURLWithPathComponents:(NSArray *)components` → `instancetype`: Create URL from path component array
- `- initFileURLWithPath:(NSString *)path` → `instancetype`: Initialize file URL
- `- initFileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir` → `instancetype`: Initialize file URL (with hint)

#### Filesystem Path Access

- `- fileSystemRepresentation` → `char *`: Get C string path in filesystem encoding
- `- getFileSystemRepresentation:(char *)buf maxLength:(NSUInteger)max` → `BOOL`: Copy path to buffer

#### Constants

- `NSURLFileScheme` (@"file"): File URL scheme constant

### NSData (NSURL) Category

#### Loading Data from URLs

- `+ dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)options error:(NSError **)error` → `instancetype`: Read data from URL with options
- `+ dataWithContentsOfURL:(NSURL *)url` → `instancetype`: Read data from URL (simple)
- `- initWithContentsOfURL:(NSURL *)url` → `instancetype`: Initialize from URL data

#### Writing Data to URLs

- `- writeToURL:(NSURL *)url atomically:(BOOL)flag` → `BOOL`: Write data to URL destination

#### Options (NSDataReadingOptions)

```objc
NSDataReadingMappedIfSafe    // Mmap if safe
NSDataReadingUncached        // Don't cache in memory
NSDataReadingMappedAlways    // Always use mmap
```

### NSHost (OS) Category

#### Current System Information

- `+ currentHost` → `instancetype`: Get current system's host object

### Base NSHost API Reference

#### Host Lookup

- `+ hostWithName:(NSString *)name` → `instancetype`: Lookup host by name
- `+ hostWithAddress:(NSString *)address` → `instancetype`: Lookup host by address
- `+ currentHost` → `instancetype`: Get current host information

#### Host Information

- `- name` → `NSString *`: Official hostname
- `- address` → `NSString *`: Primary IP address
- `- addresses` → `NSArray *`: All IP addresses
- `- names` → `NSArray *`: All hostnames (aliases)

## 4. Performance Characteristics

- **File URL Creation**: O(1) path parsing and encoding
- **Path Representation**: O(1) conversion to C string
- **Data Loading**: O(n) disk I/O for file data; network I/O for remote URLs
- **Host Lookup**: O(1) for currentHost; O(n) for DNS lookups (blocking)
- **Filesystem Encoding**: Platform-specific (UTF-8 on Unix, UTF-16 on Windows)
- **Caching**: OS typically caches DNS and filesystem metadata

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use File URLs**: Prefer file:// URLs for filesystem operations (platform-portable)
- **Atomic Writes**: Use atomically:YES for safe file writes
- **Error Checking**: Always check error parameter for data operations
- **Path Components**: Use fileURLWithPathComponents: for portable path building
- **Filesystem Encoding**: Use fileSystemRepresentation for correct encoding
- **Host Caching**: Cache host lookups; DNS is slow and blocking

### Common Pitfalls

- **URL vs Path**: URLs are different from paths; use appropriate methods
- **File Scheme**: Not all URLs are file URLs; check scheme before filesystem ops
- **Path Encoding**: Filesystem encoding varies by OS; use fileSystemRepresentation
- **DNS Blocking**: Host lookups block; don't call in UI thread
- **Directory Hints**: File URL creation benefits from isDirectory hint (improves behavior)
- **Relative URLs**: Can't determine if relative URL is file/directory; use absolute URLs

### Idiomatic Usage

```objc
// Pattern 1: Create and use file URLs
NSURL *fileURL = [NSURL fileURLWithPath:@"/tmp/file.txt"];
NSError *error = nil;
NSData *data = [NSData dataWithContentsOfURL:fileURL 
                                    options:NSDataReadingUncached 
                                      error:&error];

// Pattern 2: Save data to URL
NSData *content = [@"Hello" dataUsingEncoding:NSUTF8StringEncoding];
[content writeToURL:fileURL atomically:YES];

// Pattern 3: Get filesystem representation
NSURL *url = [NSURL fileURLWithPath:@"/tmp/test"];
char *cpath = [url fileSystemRepresentation];

// Pattern 4: Build path components
NSArray *components = @[@"Users", @"username", @"Documents", @"file.txt"];
NSURL *docURL = [NSURL fileURLWithPathComponents:components];

// Pattern 5: Current host info
NSHost *localHost = [NSHost currentHost];
NSLog(@"Hostname: %@", [localHost name]);
```

## 6. Integration Examples

### Example 1: Create and Use File URLs

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    NSString *path = @"/tmp/test.txt";
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    NSLog(@"URL: %@", fileURL);
    NSLog(@"Scheme: %@", [fileURL scheme]);
    NSLog(@"Path: %@", [fileURL path]);
    
    return 0;
}
```

### Example 2: Read Data from File URL

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    // Create file with content
    NSString *content = @"Hello, World!";
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:@"/tmp/test.txt" atomically:YES];
    
    // Read via file URL
    NSURL *fileURL = [NSURL fileURLWithPath:@"/tmp/test.txt"];
    NSError *error = nil;
    NSData *readData = [NSData dataWithContentsOfURL:fileURL
                                             options:0
                                               error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return 1;
    }
    
    NSString *readContent = [[NSString alloc] initWithData:readData 
                                                   encoding:NSUTF8StringEncoding];
    NSLog(@"Content: %@", readContent);
    [readContent release];
    
    return 0;
}
```

### Example 3: Write Data to File URL

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    NSURL *fileURL = [NSURL fileURLWithPath:@"/tmp/output.txt"];
    
    NSString *data = @"Data to write";
    NSData *bytes = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL success = [bytes writeToURL:fileURL atomically:YES];
    
    if (success) {
        NSLog(@"Written successfully to %@", fileURL);
    } else {
        NSLog(@"Write failed");
    }
    
    return 0;
}
```

### Example 4: Build URL from Path Components

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    NSArray *components = @[@"tmp", @"mydir", @"file.txt"];
    NSURL *url = [NSURL fileURLWithPathComponents:components];
    
    NSLog(@"URL: %@", url);
    NSLog(@"Path: %@", [url path]);
    
    // Verify components
    NSString *reconstructed = [[url path] stringByReplacingOccurrencesOfString:@"//" 
                                                                     withString:@"/"];
    NSLog(@"Reconstructed path: %@", reconstructed);
    
    return 0;
}
```

### Example 5: Filesystem Representation

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    NSURL *fileURL = [NSURL fileURLWithPath:@"/tmp/test.txt"];
    
    // Get C string in filesystem encoding
    char *cPath = [fileURL fileSystemRepresentation];
    printf("C path: %s\n", cPath);
    
    // Or use buffer method
    char buffer[1024];
    BOOL success = [fileURL getFileSystemRepresentation:buffer maxLength:1024];
    
    if (success) {
        printf("Buffer path: %s\n", buffer);
    }
    
    return 0;
}
```

### Example 6: Directory Hint for File URLs

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    // Create URL for directory with isDirectory hint
    NSURL *dirURL = [NSURL fileURLWithPath:@"/tmp/mydir" isDirectory:YES];
    NSLog(@"Directory URL: %@", dirURL);
    
    // Create URL for file with isDirectory:NO
    NSURL *fileURL = [NSURL fileURLWithPath:@"/tmp/file.txt" isDirectory:NO];
    NSLog(@"File URL: %@", fileURL);
    
    return 0;
}
```

### Example 7: Current Host Information

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    NSHost *localHost = [NSHost currentHost];
    
    NSLog(@"Hostname: %@", [localHost name]);
    NSLog(@"Address: %@", [localHost address]);
    
    NSArray *addresses = [localHost addresses];
    for (NSString *addr in addresses) {
        NSLog(@"  - %@", addr);
    }
    
    NSArray *names = [localHost names];
    for (NSString *name in names) {
        NSLog(@"  Alias: %@", name);
    }
    
    return 0;
}
```

### Example 8: Error Handling

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    NSURL *badURL = [NSURL fileURLWithPath:@"/nonexistent/path.txt"];
    NSError *error = nil;
    
    NSData *data = [NSData dataWithContentsOfURL:badURL
                                        options:0
                                          error:&error];
    
    if (error) {
        NSLog(@"Error reading file:");
        NSLog(@"  Domain: %@", [error domain]);
        NSLog(@"  Code: %ld", (long)[error code]);
        NSLog(@"  Description: %@", [error localizedDescription]);
        return 1;
    }
    
    NSLog(@"Read %lu bytes", [data length]);
    return 0;
}
```

### Example 9: Portable File Path Building

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    // Instead of hardcoding "/" separators, use path components
    // Works consistently across Windows and Unix
    
    NSArray *userDocPath = @[@"Users", @"alice", @"Documents", @"project", @"data.txt"];
    NSURL *url = [NSURL fileURLWithPathComponents:userDocPath];
    
    NSLog(@"Portable URL: %@", url);
    
    // Read file
    NSError *error = nil;
    NSData *fileData = [NSData dataWithContentsOfURL:url
                                            options:NSDataReadingMappedIfSafe
                                              error:&error];
    
    if (!error) {
        NSLog(@"Loaded %lu bytes", [fileData length]);
    }
    
    return 0;
}
```

### Example 10: Batch File Operations

```objc
#import <MulleObjCInetOSFoundation/MulleObjCInetOSFoundation.h>

int main() {
    NSArray *filePaths = @[@"/tmp/file1.txt", @"/tmp/file2.txt", @"/tmp/file3.txt"];
    
    for (NSString *path in filePaths) {
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        
        NSData *data = [NSData dataWithContentsOfURL:url
                                            options:0
                                              error:&error];
        
        if (error) {
            NSLog(@"Failed to read %@: %@", path, [error localizedDescription]);
        } else {
            NSLog(@"Read %lu bytes from %@", [data length], path);
        }
    }
    
    return 0;
}
```

## 7. Dependencies

- MulleObjCInetFoundation (NSHost, NSURL base classes)
- MulleObjCOSFoundation (filesystem integration)
- MulleObjCValueFoundation (NSString, NSData)
- MulleFoundationBase

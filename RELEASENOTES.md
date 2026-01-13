### 0.20.7

Various small improvements

### 0.20.6

Various small improvements

### 0.20.5

Various small improvements

### 0.20.4

* Various small improvements

### 0.20.3

* Various small improvements

### 0.20.2

* Various small improvements

### 0.20.1

* change GLOBAL for Windows

## 0.20.0

* Various small improvements


## 0.19.0

* Various small improvements


## 0.18.0

* Various small improvements


### 0.17.2

* remove duplicate objc-loader.inc

### 0.17.1

* new mulle-sde project structure

## 0.17.0

* split off from MulleObjCOSFoundation
* cut dependency on MulleObjCInetFoundation, move some code to new MulleObjCOSInetFoundation
* NSString's ``_stringBySimplifyingPath`` is now `mulleStringBySimplifyingPath`
* NSTimeZone`s ``_GMTTimeZone`` is now `mulleGMTTimeZone`
* adapted to changes in MulleObjC
* add mulleWriteBytes:length: method to NSFileHandle
* move NSConditionLock to MulleFoundation
* fix NSCondition a little bit
* fix timeIntervalSince1970 miscalculation in NSDate
* add pre-cursory Windows subproject
* add memory mapped NSData (read only) based on mulle-mmap
* fix infinite recursion on Darwin
* improved NSRunLoop can now do performMessages and NSTimer
* multiple bugfixes with proper handling of nil parameters
* added NSURLFileScheme to NSURL
* improved NSBundle
* added MulleDateNow() function and based NSDate on gettimeofday instead of time
* fix stringByResolvingSymlinksInPath and stringByStandardizingPath
* fix leak with GMT Timezone
* fix unavoidable setProcessName leak tripping up tests
* rename many `_methods` to mulleMethods, to distinguish between private and just not compatible
* added some of the uncherished error:(NSError **) error method variations for compatibility
* improved `_stringBySimplifyingPath`
* added some more "well known" directory names, such as NSTrashDirectonary
* improved NSBundle, NSFileHandle, NSFileManager, NSProcessInfo, NSError
* modernized to new mulle-test
* fix some compile warnings (use fork for Posix)
* modernized project structure and tests
* modernize mulle-sde cmake, fix a test for linux
* fix for mingw
* migration to mulle-sde completed
* modernize CMakeLists.txt and CMakeDependencies.txt
* separate OS into constituent libraries, so each library has one loader only

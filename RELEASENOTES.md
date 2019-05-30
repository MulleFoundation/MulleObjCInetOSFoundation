### 0.15.1

* fix stringByResolvingSymlinksInPath and stringByStandardizingPath
* fix leak with GMT Timezone

## 0.15.0

* fix unavoidable setProcessName leak tripping up tests
* rename many `_methods` to mulleMethods, to distinguish between private and just not compatible
* added some of the uncherished error:(NSError **) error method variations for compatibility
* improved `_stringBySimplifyingPath`
* added some more "well known" directory names, such as NSTrashDirectonary
* improved NSBundle, NSFileHandle, NSFileManager, NSProcessInfo, NSError


### 0.14.1

* modernized to new mulle-test

## 0.14.0

* modernized project structure and tests


### 0.13.2

* modernize mulle-sde cmake, fix a test for linux

### 0.13.1

* fix for mingw

## 0.13.0

* migration to mulle-sde completed


### 0.12.1

* Various small improvements

### 0.9.1

* modernize CMakeLists.txt and CMakeDependencies.txt 
* separate OS into constituent libraries, so each library has one loader only
* make it a cmake "C" project

# 0.2.0

* start versioning

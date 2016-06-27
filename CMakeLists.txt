cmake_minimum_required (VERSION 3.0)

# probably better to remove it, and specify as
# cmake -DCMAKE_OSX_SYSROOT=macosx ..
#
set( CMAKE_OSX_SYSROOT macosx)

project (MulleObjCPosixFoundation)


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/mulle-configuration)
message(STATUS "CMAKE_MODULE_PATH is ${CMAKE_MODULE_PATH}")
message(STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")
if( "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  include( Debug)
else()
  include( Release)
endif()

#
# -D_XOPEN_SOURCE is only needed only in CMakeLists.txt
# ObjC code is "shielded" from <unistd.h>
#
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_XOPEN_SOURCE=700")
set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_XOPEN_SOURCE=700")


include_directories(
src
src/Posix
src/Posix/Categories
src/Posix/Functions
src/Posix/Locale
src/Posix/Stream
src/Posix/Timezone
)


set( POSIX_HEADERS
src/Posix/Categories/NSArchiver+Posix.h
src/Posix/Categories/NSArray+Posix.h
src/Posix/Categories/NSDictionary+Posix.h
src/Posix/Categories/NSError+Posix.h
src/Posix/Categories/NSData+Posix.h
src/Posix/Categories/NSError+Posix.h
src/Posix/Categories/NSString+CString.h
src/Posix/Categories/NSString+Posix.h
src/Posix/Categories/NSString+PosixPathHandling.h
src/Posix/Categories/NSURL+PosixPathHandling.h
src/Posix/Functions/NSAllocation.h
src/Posix/Functions/NSLog.h
src/Posix/Functions/NSPathUtilities.h
src/Posix/NSLocale+Posix.h
src/Posix/Categories/NSString+PosixPathHandling.h
src/Posix/MulleObjCPosixFoundation.h
src/Posix/NSBundle.h
src/Posix/NSCondition.h
src/Posix/NSConditionLock.h
src/Posix/NSDirectoryEnumerator.h
src/Posix/NSFileHandle.h
src/Posix/NSFileManager.h
src/Posix/NSPipe.h
src/Posix/NSProcessInfo.h
src/Posix/NSTask+System.h
src/Posix/NSTask.h
src/Posix/NSUserDefaults.h
src/Posix/Stream/MulleObjCBufferedInputStream+InlineAccessors.h
src/Posix/Stream/MulleObjCBufferedInputStream+NSFilehandle.h
src/Posix/Stream/MulleObjCBufferedInputStream.h
src/Posix/Stream/MulleObjCBufferedOutputStream+InlineAccessors.h
src/Posix/Stream/MulleObjCBufferedOutputStream+NSFileHandle.h
src/Posix/Stream/MulleObjCBufferedOutputStream.h
src/Posix/Stream/MulleObjCStream.h
src/Posix/Timezone/NSCalendarDate.h
src/Posix/Timezone/NSDate+NSCalendarDate.h
src/Posix/Timezone/NSTimeZone+Posix.h
)

INSTALL( FILES ${POSIX_HEADERS} DESTINATION "include/MulleObjCPosixFoundation")


set( POSIX_SOURCES
src/Posix/Categories/NSArray+Posix.m
src/Posix/Categories/NSArray+PosixPrivate.m
src/Posix/Categories/NSArchiver+Posix.m
src/Posix/Categories/NSData+Posix.m
src/Posix/Categories/NSError+Posix.m
src/Posix/Categories/NSDictionary+Posix.m
src/Posix/Categories/NSDictionary+PosixPrivate.m
src/Posix/Categories/NSString+CString.m
src/Posix/Categories/NSString+Posix.m
src/Posix/Categories/NSString+PosixPathHandling.m
src/Posix/Categories/NSURL+PosixPathHandling.m
src/Posix/Functions/NSAllocation.m
src/Posix/Functions/NSLog.m
src/Posix/Functions/NSPathUtilities.m
src/Posix/MulleObjCDateFormatter.m
src/Posix/mulle_posix_tm.c
src/Posix/NSBundle.m
src/Posix/NSCondition.m
src/Posix/NSConditionLock.m
src/Posix/NSDirectoryEnumerator.m
src/Posix/NSFileHandle.m
src/Posix/NSFileManager.m
src/Posix/NSLocale+Posix.m
src/Posix/NSPipe.m
src/Posix/NSProcessInfo.m
src/Posix/NSTask+System.m
src/Posix/NSTask.m
src/Posix/NSUserDefaults.m
src/Posix/Stream/MulleObjCBufferedInputStream+NSFilehandle.m
src/Posix/Stream/MulleObjCBufferedInputStream.m
src/Posix/Stream/MulleObjCBufferedOutputStream+NSFileHandle.m
src/Posix/Stream/MulleObjCBufferedOutputStream.m
src/Posix/Stream/MulleObjCStream.m
src/Posix/Timezone/NSTimeZone+Posix.m
src/Posix/Timezone/NSCalendarDate.m
src/Posix/Timezone/NSDate+NSCalendarDate.m
src/Posix/Timezone/localtime.c
)


set( BSD_SOURCES
${POSIX_SOURCES}
src/BSD/mulle_bsd_tm.c
src/BSD/NSDate+BSD.m
src/BSD/NSCalendarDate+BSD.m
src/BSD/NSLocale+BSD.m
src/BSD/NSProcessInfo+BSD.m
src/BSD/NSTask+BSD.m
)

set( DARWIN_SOURCES
${BSD_SOURCES}
src/Darwin/NSBundle+Darwin.m
src/Darwin/NSPathUtilities+Darwin.m
src/Darwin/NSFileManager+Darwin.m
src/Darwin/NSProcessInfo+Darwin.m
src/Darwin/NSString+Darwin.m
src/Darwin/NSTask+Darwin.m
)

set( FREEBSD_SOURCES
${BSD_SOURCES}
src/FreeBSD/NSBundle+FreeBSD.m
src/FreeBSD/NSPathUtilities+FreeBSD.m
src/FreeBSD/NSProcessInfo+FreeBSD.m
src/FreeBSD/NSString+FreeBSD.m
src/FreeBSD/NSTask+FreeBSD.m
)

set( LINUX_SOURCES
${POSIX_SOURCES}
src/Linux/NSCalendarDate+Linux.m
src/Linux/NSDate+Linux.m
src/Linux/NSLocale+Linux.m
)


if( CMAKE_SYSTEM_NAME STREQUAL "Darwin")
set( SOURCES ${DARWIN_SOURCES})
endif()


if( CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
set( SOURCES ${FREEBSD_SOURCES})
endif()


if( CMAKE_SYSTEM_NAME STREQUAL "Linux")
set( SOURCES ${LINUX_SOURCES})
endif()


add_library( MulleObjCOSFoundation STATIC
src/MulleObjCOSFoundation.m
${SOURCES}
)


add_library( MulleStandaloneObjCOSFoundation SHARED
src/MulleStandaloneObjCOSFoundation.m
)


add_dependencies( MulleStandaloneObjCOSFoundation MulleObjCOSFoundation)

TARGET_LINK_LIBRARIES( MulleStandaloneObjCOSFoundation
${BEGIN_ALL_LOAD}
MulleObjCOSFoundation
MulleObjCFoundation
MulleObjC
mulle_objc_runtime
mulle_utf
mulle_sprintf
mulle_container
mulle_concurrent
mulle_aba
mulle_allocator
mulle_test_allocator
${END_ALL_LOAD}
)

INSTALL( TARGETS MulleObjCOSFoundation DESTINATION "lib")
INSTALL( TARGETS MulleStandaloneObjCOSFoundation DESTINATION "lib")


INSTALL( FILES "src/MulleObjCOSFoundation.h" DESTINATION "include/MulleObjCOSFoundation")
INSTALL( FILES "src/MulleStandaloneObjCOSFoundation.h" DESTINATION "include/MulleStandaloneObjCOSFoundation.h")

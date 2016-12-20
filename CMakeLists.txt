cmake_minimum_required (VERSION 3.0)

# probably better to remove it, and specify as
# cmake -DCMAKE_OSX_SYSROOT=macosx ..
#
set( CMAKE_OSX_SYSROOT macosx)

project (MulleObjCPosixFoundation)


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/mulle-configuration)
message(STATUS "CMAKE_MODULE_PATH is ${CMAKE_MODULE_PATH}")
message(STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")

set( MULLE_LANGUAGE "ObjC")

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
src/FreeBSD/NSFileManager+FreeBSD.m
src/FreeBSD/NSPathUtilities+FreeBSD.m
src/FreeBSD/NSProcessInfo+FreeBSD.m
src/FreeBSD/NSString+FreeBSD.m
src/FreeBSD/NSTask+FreeBSD.m
)

set( LINUX_SOURCES
${POSIX_SOURCES}
src/Linux/NSBundle+Linux.m
src/Linux/NSCalendarDate+Linux.m
src/Linux/NSDate+Linux.m
src/Linux/NSFileManager+Linux.m
src/Linux/NSLocale+Linux.m
src/Linux/NSPathUtilities+Linux.m
src/Linux/NSProcessInfo+Linux.m
src/Linux/NSString+Linux.m
src/Linux/NSTask+Linux.m
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


find_library( MULLE_ABA_LIBRARY             NAMES mulle_aba)
find_library( MULLE_ALLOCATOR_LIBRARY       NAMES mulle_allocator)
find_library( MULLE_BUFFER_LIBRARY          NAMES mulle_buffer)
find_library( MULLE_CONCURRENT_LIBRARY      NAMES mulle_concurrent)
find_library( MULLE_CONTAINER_LIBRARY       NAMES mulle_container)
find_library( MULLE_OBJC_RUNTIME_LIBRARY    NAMES mulle_objc)
find_library( MULLE_OBJC_LIBRARY            NAMES MulleObjC)
find_library( MULLE_OBJC_FOUNDATION_LIBRARY NAMES MulleObjCFoundation)
find_library( MULLE_SPRINTF_LIBRARY         NAMES mulle_sprintf)
find_library( MULLE_TEST_ALLOCATOR_LIBRARY  NAMES mulle_test_allocator)
find_library( MULLE_THREAD_LIBRARY          NAMES mulle_thread)
find_library( MULLE_UTF_LIBRARY             NAMES mulle_utf)


message(STATUS "MULLE_ABA_LIBRARY is ${MULLE_ABA_LIBRARY}")
message(STATUS "MULLE_ALLOCATOR_LIBRARY is ${MULLE_ALLOCATOR_LIBRARY}")
message(STATUS "MULLE_BUFFER_LIBRARY is ${MULLE_BUFFER_LIBRARY}")
message(STATUS "MULLE_CONCURRENT_LIBRARY is ${MULLE_CONCURRENT_LIBRARY}")
message(STATUS "MULLE_CONTAINER_LIBRARY is ${MULLE_CONTAINER_LIBRARY}")
message(STATUS "MULLE_OBJC_FOUNDATION_LIBRARY is ${MULLE_OBJC_FOUNDATION_LIBRARY}")
message(STATUS "MULLE_OBJC_LIBRARY is ${MULLE_OBJC_LIBRARY}")
message(STATUS "MULLE_OBJC_RUNTIME_LIBRARY is ${MULLE_OBJC_RUNTIME_LIBRARY}")
message(STATUS "MULLE_SPRINTF_LIBRARY is ${MULLE_SPRINTF_LIBRARY}")
message(STATUS "MULLE_TEST_ALLOCATOR_LIBRARY is ${MULLE_TEST_ALLOCATOR_LIBRARY}")
message(STATUS "MULLE_THREAD_LIBRARY is ${MULLE_THREAD_LIBRARY}")
message(STATUS "MULLE_UTF_LIBRARY is ${MULLE_UTF_LIBRARY}")


set( DEPENDENCY_LIBRARIES
${MULLE_ABA_LIBRARY}
${MULLE_ALLOCATOR_LIBRARY}
${MULLE_BUFFER_LIBRARY}
${MULLE_CONCURRENT_LIBRARY}
${MULLE_CONTAINER_LIBRARY}
${MULLE_OBJC_FOUNDATION_LIBRARY}
${MULLE_OBJC_LIBRARY}
${MULLE_OBJC_RUNTIME_LIBRARY}
${MULLE_SPRINTF_LIBRARY}
${MULLE_TEST_ALLOCATOR_LIBRARY}
${MULLE_THREAD_LIBRARY}
${MULLE_UTF_LIBRARY}
)


INSTALL( TARGETS MulleObjCOSFoundation DESTINATION "lib")
INSTALL( FILES "src/MulleObjCOSFoundation.h" DESTINATION "include/MulleObjCOSFoundation")



add_library( MulleObjCOSFoundationStandalone SHARED
src/MulleObjCOSFoundationStandalone.m
)

add_dependencies( MulleObjCOSFoundationStandalone MulleObjCOSFoundation)

TARGET_LINK_LIBRARIES( MulleObjCOSFoundationStandalone
${BEGIN_ALL_LOAD}
MulleObjCOSFoundation
${DEPENDENCY_LIBRARIES}
${END_ALL_LOAD}
)

INSTALL( TARGETS MulleObjCOSFoundationStandalone DESTINATION "lib")

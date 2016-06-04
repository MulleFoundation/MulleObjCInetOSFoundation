cmake_minimum_required (VERSION 3.0)

project (MulleObjCPosixFoundation)


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/mulle-configuration)
message(STATUS "CMAKE_MODULE_PATH is ${CMAKE_MODULE_PATH}")
message(STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")
if( "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  include( Debug)
else()
  include( Release)
endif()

include_directories(
src
src/Posix
src/Posix/Categories
src/Posix/Functions
src/Posix/Locale
src/Posix/Stream
src/Posix/Timezone
)


set( HEADERS
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
src/Posix/Functions/NSLog.h
src/Posix/Functions/NSPathUtilities+Private.h
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


add_library( MulleObjCPosixFoundation STATIC
src/Posix/Categories/NSArray+Posix.m
src/Posix/Categories/NSArray+Posix_Private.m
src/Posix/Categories/NSArchiver+Posix.m
src/Posix/Categories/NSData+Posix.m
src/Posix/Categories/NSError+Posix.m
src/Posix/Categories/NSDictionary+Posix.m
src/Posix/Categories/NSDictionary+Posix_Private.m
src/Posix/Categories/NSString+CString.m
src/Posix/Categories/NSString+Posix.m
src/Posix/Categories/NSString+PosixPathHandling.m
src/Posix/Categories/NSURL+PosixPathHandling.m
src/Posix/Functions/NSLog.m
src/Posix/Functions/NSPathUtilities.m
src/Posix/MulleObjCDateFormatter.m
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

INSTALL( TARGETS MulleObjCPosixFoundation DESTINATION "lib")
INSTALL( FILES ${HEADERS} DESTINATION "include/MulleObjCPosixFoundation")


if( CMAKE_SYSTEM_NAME STREQUAL "Darwin")
   add_library( MulleObjCDarwinFoundation STATIC
src/Darwin/NSBundle+Darwin.m
src/Darwin/NSCalendarDate+Darwin.m
src/Darwin/NSPathUtilities+Darwin.m
src/Darwin/NSFileManager+Darwin.m
src/Darwin/NSProcessInfo+Darwin.m
src/Darwin/NSString+Darwin.m
src/Darwin/NSTask+Darwin.m
)
INSTALL( TARGETS MulleObjCDarwinFoundation DESTINATION "lib")
endif()


if( CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
   add_library( MulleObjCFreeBSDFoundation STATIC
src/FreeBSD/NSBundle+FreeBSD.m
src/FreeBSD/NSPathUtilities+FreeBSD.m
src/FreeBSD/NSProcessInfo+FreeBSD.m
src/FreeBSD/NSString+FreeBSD.m
src/FreeBSD/NSTask+FreeBSD.m
)
INSTALL( TARGETS MulleObjCFreeBSDFoundation DESTINATION "lib")
endif()


if( CMAKE_SYSTEM_NAME STREQUAL "Linux")
   add_library( MulleObjCLinuxFoundation STATIC
src/Linux/NSCalendarDate+Linux.m
)
INSTALL( TARGETS MulleObjCLinuxFoundation DESTINATION "lib")
endif()


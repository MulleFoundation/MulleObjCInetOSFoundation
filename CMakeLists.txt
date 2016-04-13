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
src/Posix/Stream
src/Posix/Timezone
)


set(HEADERS
src/Posix/Categories/NSData+Posix.h
src/Posix/Categories/NSString+Posix.h
src/Posix/Categories/NSString+PosixPathHandling.h
src/Posix/Functions/NSLog.h
src/Posix/Functions/NSPathUtilities+Private.h
src/Posix/Functions/NSPathUtilities.h
src/Posix/MulleObjCPosixFoundation.h
src/Posix/NSBundle.h
src/Posix/NSCondition+NSDate.h
src/Posix/NSCondition.h
src/Posix/NSConditionLock.h
src/Posix/NSDirectoryEnumerator.h
src/Posix/NSFileHandle+NSString.h
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
src/Posix/Timezone/NSTimeZone+NSDate.h
src/Posix/Timezone/NSTimeZone+Posix.h
src/Posix/Timezone/NSTimeZone.h
)


add_library(MulleObjCPosixFoundation STATIC
src/Posix/Categories/NSArray+Posix_Private.m
src/Posix/Categories/NSData+Posix.m
src/Posix/Categories/NSDictionary+Posix_Private.m
src/Posix/Categories/NSString+Posix.m
src/Posix/Categories/NSString+PosixPathHandling.m
src/Posix/Functions/NSLog.m
src/Posix/Functions/NSPathUtilities.m
src/Posix/NSBundle.m
src/Posix/NSCondition+NSDate.m
src/Posix/NSCondition.m
src/Posix/NSConditionLock.m
src/Posix/NSDirectoryEnumerator.m
src/Posix/NSFileHandle+NSString.m
src/Posix/NSFileHandle.m
src/Posix/NSFileManager.m
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
src/Posix/Timezone/NSTimeZone+NSDate.m
src/Posix/Timezone/NSTimeZone+Posix.m
src/Posix/Timezone/NSTimeZone.m
src/Posix/Timezone/localtime.c
)


add_library(MulleObjCDarwinFoundation STATIC
src/Darwin/NSBundle+Darwin.m
src/Darwin/NSPathUtilities+Darwin.m
src/Darwin/NSProcessInfo+Darwin.m
src/Darwin/NSString+Darwin.m
src/Darwin/NSTask+Darwin.m
)

target_link_libraries( MulleObjCDarwinFoundation MulleObjCPosixFoundation )

INSTALL(TARGETS MulleObjCPosixFoundation MulleObjCDarwinFoundation DESTINATION "lib")
INSTALL(FILES ${HEADERS} DESTINATION "include/MulleObjCPosixFoundation")

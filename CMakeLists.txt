cmake_minimum_required (VERSION 3.0)

# probably better to remove it, and specify as
# cmake -DCMAKE_OSX_SYSROOT=macosx ..
#
set( CMAKE_OSX_SYSROOT macosx)

project (MulleObjCOSFoundation)


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
${CMAKE_SOURCE_DIR}/mulle-configuration/cmake)
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

## MEMO: recreate this with mulle-xcode-to-cmake 0.5.2 or better
##
## See header of CMakeSourcesAndHeaders.txt how to recreate
##
#### CMakeSourcesAndHeaders.txt GENERATED FROM XCODE PROJECT

include( CMakeSourcesAndHeaders.txt)
include( CMakeDependencies.txt)


set( DARWIN_PUBLIC_HEADERS
${MULLE_OBJC_OSBASE_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_POSIX_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_BSD_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_DARWIN_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_OS_FOUNDATION_PUBLIC_HEADERS}
)

set( DARWIN_SOURCES
${MULLE_OBJC_OSBASE_FOUNDATION_SOURCES}
${MULLE_OBJC_POSIX_FOUNDATION_SOURCES}
${MULLE_OBJC_BSD_FOUNDATION_SOURCES}
${MULLE_OBJC_DARWIN_FOUNDATION_SOURCES}
${MULLE_OBJC_OS_FOUNDATION_SOURCES}
)

set( FREE_BSD_PUBLIC_HEADERS
${MULLE_OBJC_OSBASE_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_POSIX_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_BSD_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_FREE_BSD_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_OS_FOUNDATION_PUBLIC_HEADERS}
)

set( FREE_BSD_SOURCES
${MULLE_OBJC_OSBASE_FOUNDATION_SOURCES}
${MULLE_OBJC_POSIX_FOUNDATION_SOURCES}
${MULLE_OBJC_BSD_FOUNDATION_SOURCES}
${MULLE_OBJC_FREE_BSD_FOUNDATION_SOURCES}
${MULLE_OBJC_OS_FOUNDATION_SOURCES}
)


set( LINUX_PUBLIC_HEADERS
${MULLE_OBJC_OSBASE_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_POSIX_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_LINUX_FOUNDATION_PUBLIC_HEADERS}
${MULLE_OBJC_OS_FOUNDATION_PUBLIC_HEADERS}
)

set( LINUX_SOURCES
${MULLE_OBJC_OSBASE_FOUNDATION_SOURCES}
${MULLE_OBJC_POSIX_FOUNDATION_SOURCES}
${MULLE_OBJC_LINUX_FOUNDATION_SOURCES}
${MULLE_OBJC_OS_FOUNDATION_SOURCES}
)


if( CMAKE_SYSTEM_NAME STREQUAL "Darwin")
set( CMAKE_PLATFORM_FOUND true)
set( PUBLIC_HEADERS ${DARWIN_PUBLIC_HEADERS})
set( SOURCES ${DARWIN_SOURCES})
include_directories(
    src/BSD
    src/Darwin
)
endif()


if( CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
set( CMAKE_PLATFORM_FOUND true)
set( PUBLIC_HEADERS ${FREE_BSD_PUBLIC_HEADERS})
set( SOURCES ${FREE_BSD_SOURCES})
include_directories(
    src/BSD
    src/FreeBSD
)
endif()


if( CMAKE_SYSTEM_NAME STREQUAL "Linux")
set( CMAKE_PLATFORM_FOUND true)
set( PUBLIC_HEADERS ${LINUX_PUBLIC_HEADERS})
set( SOURCES ${LINUX_SOURCES})
include_directories(
    src/Linux
)
endif()

if( NOT CMAKE_PLATFORM_FOUND)
message( STATUS "No support for ${CMAKE_SYSTEM_NAME}")
else()
message( STATUS "Building for platform ${CMAKE_SYSTEM_NAME}")
endif()


add_library( MulleObjCOSFoundation STATIC
${SOURCES}
${PUBLIC_HEADERS}
${PRIVATE_HEADERS}
CMakeDependencies.txt
CMakeSourcesAndHeaders.txt
)


target_link_libraries( MulleObjCOSFoundation
)

#
# Standalone for debugging
#
add_library( MulleObjCOSFoundationStandalone SHARED
${MULLE_OBJC_OS_FOUNDATION_STANDALONE_SOURCES}
)

add_dependencies( MulleObjCOSFoundationStandalone MulleObjCOSFoundation)


target_link_libraries( MulleObjCOSFoundationStandalone
${BEGIN_ALL_LOAD}
MulleObjCOSFoundation
${OBJC_DEPENDENCY_LIBRARIES}
${C_DEPENDENCY_LIBRARIES}
${END_ALL_LOAD}
${OS_SPECIFIC_LIBRARIES}
)

message( STATUS "OBJC_DEPENDENCY_NAMES is ${OBJC_DEPENDENCY_NAMES}")

# runs in build dir
add_custom_command( TARGET MulleObjCOSFoundationStandalone
   POST_BUILD
   COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc -v -o
           ${CMAKE_SOURCE_DIR}/src/dependencies.inc MulleObjCOSFoundation
           ${OBJC_DEPENDENCY_NAMES}
)

set( PUBLIC_HEADERS
${PUBLIC_HEADERS}
"CMakeDependencies.txt"
"src/dependencies.inc"
)

install( TARGETS MulleObjCOSFoundation MulleObjCOSFoundationStandalone DESTINATION "lib")
install( FILES ${PUBLIC_HEADERS} DESTINATION "include/MulleObjCOSFoundation")
install( FILES ${PRIVATE_HEADERS} DESTINATION "include/MulleObjCOSFoundation/private")

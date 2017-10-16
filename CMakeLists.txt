cmake_minimum_required (VERSION 3.0)

# probably better to remove it, and specify as
# cmake -DCMAKE_OSX_SYSROOT=macosx ..
#
project( MulleObjCOSFoundation C)


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
if( NOT MULLE_CREATE_DEP_FLAGS)
  set( MULLE_CREATE_DEP_FLAGS "-v")
endif()

## MEMO: recreate this with mulle-xcode-to-cmake 0.5.2 or better
##
## See header of CMakeSourcesAndHeaders.txt how to recreate
##
#### CMakeSourcesAndHeaders.txt GENERATED FROM XCODE PROJECT

set( MULLE_OBJC_OSBASE_FOUNDATION_LIBRARY ON)
set( MULLE_OBJC_LINUX_FOUNDATION_LIBRARY ON)
set( MULLE_OBJC_DARWIN_FOUNDATION_LIBRARY ON)
set( MULLE_OBJC_FREEBSD_FOUNDATION_LIBRARY ON)
set( MULLE_OBJC_BSD_FOUNDATION_LIBRARY ON)
set( MULLE_OBJC_POSIX_FOUNDATION_LIBRARY ON)
set( MULLE_OBJC_OS_FOUNDATION_LIBRARY ON)

include( CMakeDependencies.txt)
include( CMakeSourcesAndHeaders.txt)

####
#  MulleObjCOSBaseFoundation
####

if( HAVE_OSBASE)
   include_directories(
      src
      src/Base
      src/Base/Categories
      src/Base/Functions
   )

   set( PUBLIC_HEADERS
      ${PUBLIC_HEADERS}
      ${MULLE_OBJC_OSBASE_FOUNDATION_PUBLIC_HEADERS}
   )

   set( PRIVATE_HEADERS
      ${PRIVATE_HEADERS}
      ${MULLE_OBJC_OSBASE_FOUNDATION_PRIVATE_HEADERS}
   )

   add_library( MulleObjCOSBaseFoundation STATIC
      ${MULLE_OBJC_OSBASE_FOUNDATION_SOURCES}
      ${MULLE_OBJC_OSBASE_FOUNDATION_PUBLIC_HEADERS}
      ${MULLE_OBJC_OSBASE_FOUNDATION_PRIVATE_HEADERS}
      CMakeDependencies.txt
      CMakeSourcesAndHeaders.txt
   )

   # runs in build dir
   add_custom_command( TARGET MulleObjCOSBaseFoundation
      POST_BUILD
      COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc
              ${MULLE_CREATE_DEP_FLAGS}
              -o ${CMAKE_SOURCE_DIR}/src/Base/dependencies.inc
              $<TARGET_FILE:MulleObjCOSBaseFoundation>
              ${OBJC_DEPENDENCY_NAMES}
   )

   set( ALL_INSTALL_TARGETS MulleObjCOSBaseFoundation
      ${ALL_INSTALL_TARGETS}
   )
   set( STATIC_LIBRARIES $<TARGET_FILE:MulleObjCOSBaseFoundation>
      ${STATIC_LIBRARIES}
   )

  install( FILES src/Base/dependencies.inc DESTINATION "include/MulleObjCOSBaseFoundation")
  install( TARGETS MulleObjCOSBaseFoundation DESTINATION "lib")

endif()


####
#  MulleObjCPosixFoundation
####

if( HAVE_POSIX)
   include_directories(
      src/Posix
      src/Posix/Functions
      src/Posix/Timezone
   )

   set( PUBLIC_HEADERS
      ${PUBLIC_HEADERS}
      ${MULLE_OBJC_POSIX_FOUNDATION_PUBLIC_HEADERS}
   )

   set( PRIVATE_HEADERS
      ${PRIVATE_HEADERS}
      ${MULLE_OBJC_POSIX_FOUNDATION_PRIVATE_HEADERS}
   )

   add_library( MulleObjCPosixFoundation STATIC
      ${MULLE_OBJC_POSIX_FOUNDATION_SOURCES}
      ${MULLE_OBJC_POSIX_FOUNDATION_PUBLIC_HEADERS}
      ${MULLE_OBJC_POSIX_FOUNDATION_PRIVATE_HEADERS}
      CMakeDependencies.txt
      CMakeSourcesAndHeaders.txt
   )

   # runs in build dir
   add_custom_command( TARGET MulleObjCPosixFoundation
      POST_BUILD
      COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc
              ${MULLE_CREATE_DEP_FLAGS}
              -o ${CMAKE_SOURCE_DIR}/src/Posix/dependencies.inc
              $<TARGET_FILE:MulleObjCPosixFoundation>
              ${CMAKE_SOURCE_DIR}/src/Base/dependencies.inc:MulleObjCOSBaseFoundation
   )

   add_dependencies( MulleObjCPosixFoundation "MulleObjCOSBaseFoundation")

   set( ALL_INSTALL_TARGETS MulleObjCPosixFoundation
      ${ALL_INSTALL_TARGETS}
   )
   set( STATIC_LIBRARIES $<TARGET_FILE:MulleObjCPosixFoundation>
      ${STATIC_LIBRARIES}
   )

  install( FILES src/Posix/dependencies.inc DESTINATION "include/MulleObjCPosixFoundation")
  install( TARGETS MulleObjCPosixFoundation DESTINATION "lib")

endif()


####
#  MulleObjCBSDFoundation
####

if( HAVE_BSD)
   include_directories(
       src/BSD
   )

   set( PUBLIC_HEADERS
      ${PUBLIC_HEADERS}
      ${MULLE_OBJC_BSD_FOUNDATION_PUBLIC_HEADERS}
   )

   set( PRIVATE_HEADERS
      ${PRIVATE_HEADERS}
      ${MULLE_OBJC_BSD_FOUNDATION_PRIVATE_HEADERS}
   )

   add_library( MulleObjCBSDFoundation STATIC
      ${MULLE_OBJC_BSD_FOUNDATION_SOURCES}
      ${MULLE_OBJC_BSD_FOUNDATION_PUBLIC_HEADERS}
      ${MULLE_OBJC_BSD_FOUNDATION_PRIVATE_HEADERS}
      CMakeDependencies.txt
      CMakeSourcesAndHeaders.txt
   )


   # runs in build dir
   add_custom_command( TARGET MulleObjCBSDFoundation
      POST_BUILD
      COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc
              ${MULLE_CREATE_DEP_FLAGS}
              -o ${CMAKE_SOURCE_DIR}/src/BSD/dependencies.inc
              $<TARGET_FILE:MulleObjCBSDFoundation>
              ${CMAKE_SOURCE_DIR}/src/Posix/dependencies.inc:MulleObjCPosixFoundation
   )

   add_dependencies( MulleObjCBSDFoundation "MulleObjCPosixFoundation")

   set( ALL_INSTALL_TARGETS MulleObjCBSDFoundation
      ${ALL_INSTALL_TARGETS}
   )
   set( STATIC_LIBRARIES $<TARGET_FILE:MulleObjCBSDFoundation>
      ${STATIC_LIBRARIES}
   )

  install( FILES src/BSD/dependencies.inc DESTINATION "include/MulleObjCBSDFoundation")
  install( TARGETS MulleObjCBSDFoundation DESTINATION "lib")

endif( HAVE_BSD)


####
#  MulleObjCFreeBSDFoundation
####

if( HAVE_FREEBSD)
   include_directories(
      src/FreeBSD
   )

   set( PUBLIC_HEADERS
      ${PUBLIC_HEADERS}
      ${MULLE_OBJC_FREEBSD_FOUNDATION_PUBLIC_HEADERS}
   )

   set( PRIVATE_HEADERS
      ${PRIVATE_HEADERS}
      ${MULLE_OBJC_FREEBSD_FOUNDATION_PRIVATE_HEADERS}
   )

   add_library( MulleObjCFreeBSDFoundation STATIC
      ${MULLE_OBJC_FREEBSD_FOUNDATION_SOURCES}
      ${MULLE_OBJC_FREEBSD_FOUNDATION_PUBLIC_HEADERS}
      ${MULLE_OBJC_FREEBSD_FOUNDATION_PRIVATE_HEADERS}
      CMakeDependencies.txt
      CMakeSourcesAndHeaders.txt
   )


   # runs in build dir
   add_custom_command( TARGET MulleObjCFreeBSDFoundation
      POST_BUILD
      COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc
              ${MULLE_CREATE_DEP_FLAGS}
              -o ${CMAKE_SOURCE_DIR}/src/FreeBSD/dependencies.inc
              $<TARGET_FILE:MulleObjCFreeBSDFoundation>
              ${CMAKE_SOURCE_DIR}/src/BSD/dependencies.inc:MulleObjCBSDFoundation
   )

   add_dependencies( MulleObjCFreeBSDFoundation "MulleObjCBSDFoundation")

   set( ALL_INSTALL_TARGETS MulleObjCFreeBSDFoundation
      ${ALL_INSTALL_TARGETS}
   )
   set( STATIC_LIBRARIES $<TARGET_FILE:MulleObjCFreeBSDFoundation>
      ${STATIC_LIBRARIES}
   )

  install( FILES src/FreeBSD/dependencies.inc DESTINATION "include/MulleObjCFreeBSDFoundation")
  install( TARGETS MulleObjCFreeBSDFoundation DESTINATION "lib")

endif()


####
#  MulleObjCDarwinFoundation
####

if( HAVE_DARWIN)
   include_directories(
      src/Darwin
   )

   set( PUBLIC_HEADERS
      ${PUBLIC_HEADERS}
      ${MULLE_OBJC_DARWIN_FOUNDATION_PUBLIC_HEADERS}
   )

   set( PRIVATE_HEADERS
      ${PRIVATE_HEADERS}
      ${MULLE_OBJC_DARWIN_FOUNDATION_PRIVATE_HEADERS}
   )

   add_library( MulleObjCDarwinFoundation STATIC
      ${MULLE_OBJC_DARWIN_FOUNDATION_SOURCES}
      ${MULLE_OBJC_DARWIN_FOUNDATION_PUBLIC_HEADERS}
      ${MULLE_OBJC_DARWIN_FOUNDATION_PRIVATE_HEADERS}
      CMakeDependencies.txt
      CMakeSourcesAndHeaders.txt
   )


   # runs in build dir
   add_custom_command( TARGET MulleObjCDarwinFoundation
      POST_BUILD
      COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc
              ${MULLE_CREATE_DEP_FLAGS}
              -o ${CMAKE_SOURCE_DIR}/src/Darwin/dependencies.inc
              $<TARGET_FILE:MulleObjCDarwinFoundation>
              ${CMAKE_SOURCE_DIR}/src/BSD/dependencies.inc:MulleObjCBSDFoundation
   )

   add_dependencies( MulleObjCDarwinFoundation "MulleObjCBSDFoundation")

   set( ALL_INSTALL_TARGETS MulleObjCDarwinFoundation
      ${ALL_INSTALL_TARGETS}
   )
   set( STATIC_LIBRARIES $<TARGET_FILE:MulleObjCDarwinFoundation>
      ${STATIC_LIBRARIES}
   )

  install( FILES src/Darwin/dependencies.inc DESTINATION "include/MulleObjCDarwinFoundation")
  install( TARGETS MulleObjCDarwinFoundation DESTINATION "lib")

endif()


####
#  MulleObjCLinuxFoundation
####

if( HAVE_LINUX)

   include_directories(
      src/Linux
   )

   set( PUBLIC_HEADERS
      ${PUBLIC_HEADERS}
      ${MULLE_OBJC_LINUX_FOUNDATION_PUBLIC_HEADERS}
   )

   add_library( MulleObjCLinuxFoundation STATIC
      ${MULLE_OBJC_LINUX_FOUNDATION_SOURCES}
      ${MULLE_OBJC_LINUX_FOUNDATION_PUBLIC_HEADERS}
      ${MULLE_OBJC_LINUX_FOUNDATION_PRIVATE_HEADERS}
      CMakeDependencies.txt
      CMakeSourcesAndHeaders.txt
   )


   # runs in build dir
   add_custom_command( TARGET MulleObjCLinuxFoundation
      POST_BUILD
      COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc
              ${MULLE_CREATE_DEP_FLAGS}
              -o ${CMAKE_SOURCE_DIR}/src/Linux/dependencies.inc
              $<TARGET_FILE:MulleObjCLinuxFoundation>
              ${CMAKE_SOURCE_DIR}/src/Posix/dependencies.inc:MulleObjCPosixFoundation
   )

   add_dependencies( MulleObjCLinuxFoundation "MulleObjCPosixFoundation")

   set( ALL_INSTALL_TARGETS MulleObjCLinuxFoundation
      ${ALL_INSTALL_TARGETS}
   )
   set( STATIC_LIBRARIES $<TARGET_FILE:MulleObjCLinuxFoundation>
      ${STATIC_LIBRARIES}
   )

  install( FILES src/Linux/dependencies.inc DESTINATION "include/MulleObjCLinuxFoundation")
  install( TARGETS MulleObjCLinuxFoundation DESTINATION "lib")

endif()


####
#  MulleObjCOSFoundation
####

add_library( MulleObjCOSFoundation STATIC
${MULLE_OBJC_OS_FOUNDATION_SOURCES}
${PUBLIC_HEADERS}
${PRIVATE_HEADERS}
CMakeDependencies.txt
CMakeSourcesAndHeaders.txt
)

# runs in build dir
add_custom_command( TARGET MulleObjCOSFoundation
   POST_BUILD
   COMMAND ${DEPENDENCIES_DIR}/bin/mulle-objc-create-dependencies-inc
           ${MULLE_CREATE_DEP_FLAGS}
           -o ${CMAKE_SOURCE_DIR}/src/dependencies.inc
           MulleObjCOSFoundation
           ${CMAKE_SOURCE_DIR}/src/${CMAKE_SYSTEM_NAME}/dependencies.inc:MulleObjC${CMAKE_SYSTEM_NAME}Foundation
)


add_dependencies( MulleObjCOSFoundation "MulleObjC${CMAKE_SYSTEM_NAME}Foundation")


set( PUBLIC_HEADERS
   ${PUBLIC_HEADERS}
   ${MULLE_OBJC_OS_FOUNDATION_PUBLIC_HEADERS}
)

set( PRIVATE_HEADERS
   ${PRIVATE_HEADERS}
   ${MULLE_OBJC_OS_FOUNDATION_PRIVATE_HEADERS}
)

set( ALL_INSTALL_TARGETS MulleObjCOSFoundation
   ${ALL_INSTALL_TARGETS}
)

set( STATIC_LIBRARIES $<TARGET_FILE:MulleObjCOSFoundation>
   ${STATIC_LIBRARIES}
)


set( PUBLIC_HEADERS
${PUBLIC_HEADERS}
"CMakeDependencies.txt"
"src/dependencies.inc"
)


set( OBJC_LIBRARY_NAME "MulleObjCOSFoundation")

include( DependenciesIncObjC)


#
# produce a standalone dll/dylib/so for testing mainly
# though testing could go static at some point in time
# (shared is more frugal though)
#
set( STANDALONE_BASE_NAME "${OBJC_LIBRARY_NAME}")
set( STANDALONE_NAME "${OBJC_LIBRARY_NAME}Standalone")
set( STANDALONE_SOURCES ${MULLE_OBJC_OS_FOUNDATION_STANDALONE_SOURCES})
set( STANDALONE_DEFINITIONS ${MULLE_OBJC_OS_FOUNDATION_DEFINITIONS})
set( STANDALONE_ALL_LOAD_LIBRARIES
    ${OBJC_DEPENDENCY_LIBRARIES}
    ${OBJC_STARTUP_LIBRARY}
    ${C_DEPENDENCY_LIBRARIES}
    ${STATIC_LIBRARIES}
)

include( Standalone)

install( TARGETS MulleObjCOSFoundation MulleObjCOSFoundationStandalone DESTINATION "lib")
install( FILES ${PUBLIC_HEADERS} DESTINATION "include/MulleObjCOSFoundation")
install( FILES ${PRIVATE_HEADERS} DESTINATION "include/MulleObjCOSFoundation/private")

include( MulleTest)

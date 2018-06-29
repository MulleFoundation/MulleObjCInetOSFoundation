cmake_minimum_required( VERSION 3.1)

project( MulleObjCFreeBSDFoundation C)


### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")

include( Environment)


### Files

include( PreFiles OPTIONAL)

set( MULLE_OBJC_FREEB_SDFOUNDATION_LIBRARY ON)

#
# Include all non underscored .cmake files in ./cmake
#
file( GLOB LOCAL_CMAKE_INCLUDES
   "cmake/[A-Za-z0-9]*.cmake"
)

foreach( FILE ${LOCAL_CMAKE_INCLUDES} )
   include( "${FILE}")
endforeach()


include_directories( ${INCLUDE_DIRS})

include( PostFiles OPTIONAL)

set( PROJECT_FILES
   ${PROJECT_FILES}
   ${SOURCES}
   ${PUBLIC_HEADERS}
   ${PRIVATE_HEADERS}
   ${CMAKE_EDITABLE_FILES}
)

### Library

include( PreLibrary OPTIONAL)

add_library( "MulleObjCFreeBSDFoundation"
   ${PROJECT_FILES}
)

# useful for mulle-c, but can be commented out
set_property( TARGET MulleObjCFreeBSDFoundation PROPERTY CXX_STANDARD 11)


set( INSTALL_LIBRARY_TARGETS
   "MulleObjCFreeBSDFoundation"
)

include( PostLibrary OPTIONAL)

#
# defined by cmake -DBUILD_SHARED_LIBS=ON
#
if( BUILD_SHARED_LIBS)
   set( SHARED_LIBRARY_LIST
      ${DEPENDENCY_LIBRARIES}
      ${OPTIONAL_DEPENDENCY_LIBRARIES}
      ${OS_SPECIFIC_LIBRARIES}
   )

   include( PostSharedLibrary OPTIONAL) # additional hook

   target_link_libraries( MulleObjCFreeBSDFoundation
      ${SHARED_LIBRARY_LIST}
   )
endif()


### Install

include( PreInstall OPTIONAL)

install( TARGETS ${INSTALL_LIBRARY_TARGETS} DESTINATION "lib")
install( FILES ${PUBLIC_HEADERS}  DESTINATION "include/MulleObjCFreeBSDFoundation")
install( FILES ${PRIVATE_HEADERS} DESTINATION "include/MulleObjCFreeBSDFoundation/private")

install( FILES ${CMAKE_INCLUDES}  DESTINATION "include/MulleObjCFreeBSDFoundation/cmake")

include( PostInstall OPTIONAL)

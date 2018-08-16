# cmake/_Libraries.cmake is generated by `mulle-sde`. Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

if( NOT MULLE_OBJC_POSIX_FOUNDATION_HEADER)
   find_file( MULLE_OBJC_POSIX_FOUNDATION_HEADER NAMES MulleObjCPosixFoundation/MulleObjCPosixFoundation.h MulleObjCPosixFoundation.h)
   message( STATUS "MULLE_OBJC_POSIX_FOUNDATION_HEADER is ${MULLE_OBJC_POSIX_FOUNDATION_HEADER}")
   set( ALL_LOAD_HEADER_ONLY_LIBRARIES
      ${MULLE_OBJC_POSIX_FOUNDATION_HEADER}
      ${ALL_LOAD_HEADER_ONLY_LIBRARIES}
      CACHE INTERNAL "need to cache this"
   )
   if( MULLE_OBJC_POSIX_FOUNDATION_HEADER)
      # search for DependenciesAndLibraries.cmake to include
      get_filename_component( _TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT "${MULLE_OBJC_POSIX_FOUNDATION_HEADER}" DIRECTORY)
      get_filename_component( _TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT}" NAME)
      get_filename_component( _TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT}" DIRECTORY)
      get_filename_component( _TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT}" DIRECTORY)
      message( STATUS "_TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME is ${_TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME}")
      message( STATUS "_TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT is ${_TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT}")
      # search for DependenciesAndLibraries.cmake to include
      foreach( _TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME IN LISTS _TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME)
         set( _TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME}/cmake")
         # use explicit path to avoid "surprises"
         message( STATUS "_TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR is ${_TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR}")
         if( EXISTS "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR}/DependenciesAndLibraries.cmake")
            unset( MULLE_OBJC_POSIX_FOUNDATION_DEFINITIONS)
            list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR}")
            # we only want top level INHERIT_OBJC_LOADERS, so disable them
            if( NOT NO_INHERIT_OBJC_LOADERS)
               set( NO_INHERIT_OBJC_LOADERS OFF)
            endif()
            list( APPEND _TMP_INHERIT_OBJC_LOADERS ${NO_INHERIT_OBJC_LOADERS})
            set( NO_INHERIT_OBJC_LOADERS ON)
            #
            include( "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR}/DependenciesAndLibraries.cmake")
            #
            list( GET _TMP_INHERIT_OBJC_LOADERS -1 NO_INHERIT_OBJC_LOADERS)
            list( REMOVE_AT _TMP_INHERIT_OBJC_LOADERS -1)
            #
            list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR}")
            set( INHERITED_DEFINITIONS
               ${INHERITED_DEFINITIONS}
               ${MULLE_OBJC_POSIX_FOUNDATION_DEFINITIONS}
               CACHE INTERNAL "need to cache this"
            )
            break()
         else()
            message( STATUS "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_DIR}/DependenciesAndLibraries.cmake not found")
         endif()
      endforeach()

      # search for objc-loader.inc in include directory
      # this can be turned  off (see above)
      if( NOT NO_INHERIT_OBJC_LOADERS)
         foreach( _TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME IN LISTS _TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME)
            set( _TMP_MULLE_OBJC_POSIX_FOUNDATION_FILE "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_POSIX_FOUNDATION_NAME}/objc-loader.inc")
            if( EXISTS "${_TMP_MULLE_OBJC_POSIX_FOUNDATION_FILE}")
               set( INHERITED_OBJC_LOADERS
                  ${INHERITED_OBJC_LOADERS}
                  ${_TMP_MULLE_OBJC_POSIX_FOUNDATION_FILE}
                  CACHE INTERNAL "need to cache this"
               )
               break()
            endif()
         endforeach()
      endif()
   else()
      message( FATAL_ERROR "MULLE_OBJC_POSIX_FOUNDATION_HEADER was not found")
   endif()
endif()

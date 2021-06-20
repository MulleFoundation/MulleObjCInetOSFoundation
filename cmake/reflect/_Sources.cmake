#
# This file will be included by cmake/share/sources.cmake
#
# cmake/reflect/_Sources.cmake is generated by `mulle-sde reflect`.
# Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# contents selected with patternfile ??-source--sources
#
set( SOURCES
src/MulleObjCInetOSFoundation.m
src/MulleObjCInetOSFoundation-shlib.c
src/NSData+NSURL.m
src/NSHost+OS.m
src/NSURL+Filesystem.m
)

#
# contents selected with patternfile ??-source--stage2-sources
#
set( STAGE2_SOURCES
src/MulleObjCLoader+MulleObjCInetOSFoundation.m
)

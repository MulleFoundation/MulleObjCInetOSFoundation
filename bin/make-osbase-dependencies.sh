#! /bin/sh


# only runs on OS X out of the box


#
# get path for mulle-objc-list
#
eval `mulle-bootstrap paths path`

DEPENDENCIES="`mulle-bootstrap paths dependencies`"
if [ ! -f "${DEPENDENCIES}/lib/libMulleObjCInetFoundationStandalone.dylib" ]
then
   echo "libMulleObjCInetFoundationStandalone.dylib not found, mulle-bootstrap first" >&2
   exit 1
fi

if [ ! -f "build/libMulleObjCOSFoundationStandalone.dylib" ]
then
   echo "build/libMulleObjCOSFoundationStandalone.dylib not found, mulle-build first" >&2
   exit 1
fi

#
# First get all classes and categories "below" OS for later removal
# Then get all standalone classes, but remove Posix classes and
# OS specifica. The remainder are osbase-dependencies
#
mulle-objc-list -d "${DEPENDENCIES}/lib/libMulleObjCInetFoundationStandalone.dylib" > /tmp/minus.inc || exit 1
mulle-objc-list -d "build/libMulleObjCOSFoundationStandalone.dylib" | \
   egrep -w -v "MulleObjCPosixDateFormatter|MulleObjCLoader|NSCondition|Posix|BSD|FreeBSD|Linux|Darwin"  > /tmp/plus.inc || exit 1
fgrep -x -v -f/tmp/minus.inc /tmp/plus.inc > src/Base/osbase-dependencies.inc  || exit 1

echo "src/Base/osbase-dependencies.inc written" >&2
exit 0

#! /bin/sh

mulle-xcode-to-cmake -t MulleObjCOSFoundation \
                     -t MulleObjCOSFoundationStandalone \
                     -t MulleObjCOSBaseFoundation \
                     -t MulleObjCPosixFoundation \
                     -t MulleObjCBSDFoundation \
                     -t MulleObjCLinuxFoundation \
                     -t MulleObjCFreeBSDFoundation \
                     -t MulleObjCDarwinFoundation \
                     sexport MulleObjCOSFoundation.xcodeproj \
   > CMakeSourcesAndHeaders.txt

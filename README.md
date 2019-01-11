# MulleObjCOSFoundation

💻 Platform-dependent classes and categories like NSTask, NSPipe

These classes build on **MulleObjCStandardFoundation** and provide OS-specific
functionality. It also adds categories on NSString to deal with the native
C String encoding

It builds differently on each platform.

Build Status | Release Version
-------------|-----------------------------------
[![Build Status](https://travis-ci.org/MulleFoundation/MulleObjCOSFoundation.svg?branch=release)](https://travis-ci.org/MulleFoundation/MulleObjCOSFoundation) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleFoundation/MulleObjCOSFoundation.svg) [![Build Status](https://travis-ci.org/MulleFoundation/MulleObjCOSFoundation.svg?branch=release)](https://travis-ci.org/MulleFoundation/MulleObjCOSFoundation)

> Note: a few tests fail because of missing implementations.

## Install

See [foundation-developer](//github.com//foundation-developer) for
installation instructions.


## Author

[Nat!](//www.mulle-kybernetik.com/weblog) for
[Mulle kybernetiK](//www.mulle-kybernetik.com) and
[Codeon GmbH](//www.codeon.de)


#### MEMO: WARUM KOMMEN DIE ÄNDERUNGEN NICHT AN

mulle-test kann nur mulle-craft aufrufen und weiss nix von den subprojects.
Die sind aber wie "dependencies" und werden dann dazugelinkt. Änderungen kriegt
man mit mulle-test clean nicht rein, man muss mulle-sde craft machen.

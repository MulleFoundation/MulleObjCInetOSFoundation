# MulleObjCInetOSFoundation

#### 📠💻 OS specific extensions to NSHost and NSURL

**MulleObjCInetOSFoundation** contains the NSURL specific parts from
[MulleObjCOSFoundation](//github.com/MulleFoundation/MulleObjCOSFoundation) and adds them to
[MulleObjCInetFoundation](//github.com/MulleWeb/MulleObjCInetFoundation).


| Release Version                                       | Release Notes  | AI Documentation
|-------------------------------------------------------|----------------|---------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleFoundation/MulleObjCInetOSFoundation.svg) [![Build Status](https://github.com/MulleFoundation/MulleObjCInetOSFoundation/workflows/CI/badge.svg)](//github.com/MulleFoundation/MulleObjCInetOSFoundation/actions) | [RELEASENOTES](RELEASENOTES.md) | [DeepWiki for MulleObjCInetOSFoundation](https://deepwiki.com/MulleFoundation/MulleObjCInetOSFoundation)






## Requirements

|   Requirement         | Release Version  | Description
|-----------------------|------------------|---------------
| [MulleObjCInetFoundation](https://github.com/MulleWeb/MulleObjCInetFoundation) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleWeb/MulleObjCInetFoundation.svg) [![Build Status](https://github.com/MulleWeb/MulleObjCInetFoundation/workflows/CI/badge.svg?branch=release)](https://github.com/MulleWeb/MulleObjCInetFoundation/actions/workflows/mulle-sde-ci.yml) | 📠 Internet-related classes like NSHost and NSURL for mulle-objc
| [MulleObjCOSFoundation](https://github.com/MulleFoundation/MulleObjCOSFoundation) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleFoundation/MulleObjCOSFoundation.svg) [![Build Status](https://github.com/MulleFoundation/MulleObjCOSFoundation/workflows/CI/badge.svg?branch=release)](https://github.com/MulleFoundation/MulleObjCOSFoundation/actions/workflows/mulle-sde-ci.yml) | 💻 Platform-dependent classes and categories like NSTask, NSPipe
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag/mulle-objc/mulle-objc-list.svg) [![Build Status](https://github.com/mulle-objc/mulle-objc-list/workflows/CI/badge.svg?branch=release)](https://github.com/mulle-objc/mulle-objc-list/actions/workflows/mulle-sde-ci.yml) | 📒 Lists mulle-objc runtime information contained in executables.

### You are here

![Overview](overview.dot.svg)

## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleObjCInetOSFoundation to your project:

``` sh
mulle-sde add github:MulleFoundation/MulleObjCInetOSFoundation
```

## Install

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleObjCInetOSFoundation and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/MulleFoundation/MulleObjCInetOSFoundation/archive/latest.tar.gz
```

### Legacy Installation

Install the requirements:

| Requirements                                 | Description
|----------------------------------------------|-----------------------
| [MulleObjCInetFoundation](https://github.com/MulleWeb/MulleObjCInetFoundation)             | 📠 Internet-related classes like NSHost and NSURL for mulle-objc
| [MulleObjCOSFoundation](https://github.com/MulleFoundation/MulleObjCOSFoundation)             | 💻 Platform-dependent classes and categories like NSTask, NSPipe
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list)             | 📒 Lists mulle-objc runtime information contained in executables.

Download the latest [tar](https://github.com/MulleFoundation/MulleObjCInetOSFoundation/archive/refs/tags/latest.tar.gz) or [zip](https://github.com/MulleFoundation/MulleObjCInetOSFoundation/archive/refs/tags/latest.zip) archive and unpack it.

Install **MulleObjCInetOSFoundation** into `/usr/local` with [cmake](https://cmake.org):

``` sh
PREFIX_DIR="/usr/local"
cmake -B build                               \
      -DMULLE_SDK_PATH="${PREFIX_DIR}"       \
      -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
      -DCMAKE_PREFIX_PATH="${PREFIX_DIR}"    \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```

## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  



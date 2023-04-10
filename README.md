# MulleObjCInetOSFoundation

#### 📠💻 OS specific extensions to NSHost and NSURL

**MulleObjCInetOSFoundation** contains the NSURL specific parts from
[MulleObjCOSFoundation](//github.com/MulleFoundation/MulleObjCOSFoundation) and adds them to
[MulleObjCInetFoundation](//github.com/MulleWeb/MulleObjCInetFoundation).

| Release Version                                       | Release Notes
|-------------------------------------------------------|--------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag//MulleObjCInetOSFoundation.svg?branch=release) [![Build Status](https://github.com//MulleObjCInetOSFoundation/workflows/CI/badge.svg?branch=release)](//github.com//MulleObjCInetOSFoundation/actions)| [RELEASENOTES](RELEASENOTES.md) |





## Requirements

|   Requirement         | Release Version  | Description
|-----------------------|------------------|---------------
| [MulleObjCInetFoundation](https://github.com/MulleWeb/MulleObjCInetFoundation) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag//.svg) [![Build Status](https://github.com///workflows/CI/badge.svg?branch=release)](https://github.com///actions/workflows/mulle-sde-ci.yml) | 📠 Internet-related classes like NSHost and NSURL for mulle-objc
| [MulleObjCOSFoundation](https://github.com/MulleFoundation/MulleObjCOSFoundation) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag//.svg) [![Build Status](https://github.com///workflows/CI/badge.svg?branch=release)](https://github.com///actions/workflows/mulle-sde-ci.yml) | 💻 Platform-dependent classes and categories like NSTask, NSPipe
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag//.svg) [![Build Status](https://github.com///workflows/CI/badge.svg?branch=release)](https://github.com///actions/workflows/mulle-sde-ci.yml) | 📒 Lists mulle-objc runtime information contained in executables.

### You are here

![Overview](overview.dot.svg)

## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleObjCInetOSFoundation to your project:

``` sh
mulle-sde add github:MulleFoundation/MulleObjCInetOSFoundation
```

## Install

### Install with mulle-sde

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleObjCInetOSFoundation and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/MulleFoundation/MulleObjCInetOSFoundation/archive/latest.tar.gz
```

### Manual Installation

Install the requirements:

| Requirements                                 | Description
|----------------------------------------------|-----------------------
| [MulleObjCInetFoundation](https://github.com/MulleWeb/MulleObjCInetFoundation)             | 📠 Internet-related classes like NSHost and NSURL for mulle-objc
| [MulleObjCOSFoundation](https://github.com/MulleFoundation/MulleObjCOSFoundation)             | 💻 Platform-dependent classes and categories like NSTask, NSPipe
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list)             | 📒 Lists mulle-objc runtime information contained in executables.

Install **MulleObjCInetOSFoundation** into `/usr/local` with [cmake](https://cmake.org):

``` sh
cmake -B build \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_PREFIX_PATH=/usr/local \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```

## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK



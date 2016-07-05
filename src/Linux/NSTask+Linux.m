//
//  NSTask+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 29.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation



@implementation NSTask( Linux)

+ (char **) _environment
{
   extern char  **environ;
   
   return( environ);
}

@end

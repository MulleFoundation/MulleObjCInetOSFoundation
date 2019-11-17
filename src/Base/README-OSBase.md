# OSBase

OSBase introduces a number of OS related base classes.

Class             | Related Unix syscalls
------------------|----------------------
NSBundle          | ldopen
NSFileHandle      | open,creat,read,write,lseek
NSFileManager     | readdir
NSProcessInfo     | /dev/proc
NSRunLoop         | select
NSUserDefaults    | dsctl
NSTask            | fork, execve
NSPipe            | pipe

There are categories on ObjCFoundation classes, that use the abstract
functionality provided by those classes.

No system specific headers are used.


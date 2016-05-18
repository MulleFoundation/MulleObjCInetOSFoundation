
## Dependencies

#### expat

expat on 10.10 is too old. It's probably not available per default on windows.
Building it is complicated. Solution, `brew` it and finagle compile flags
on a per platform basis.

OS X with brew:

``` 
LDFLAGS:  -L/usr/local/opt/expat/lib
CPPFLAGS: -I/usr/local/opt/expat/include
```

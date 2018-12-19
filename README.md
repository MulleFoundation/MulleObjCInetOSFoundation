# MulleObjCOSFoundation

This is a [mulle-sde](https://mulle-sde.github.io/) project.

It has it's own virtual environment, that will be automatically setup for you
once you enter it with:

```
mulle-sde MulleObjCOSFoundation
```

Now you can let **mulle-sde** fetch the required dependencies and build the
project for you:

```
mulle-sde craft
```

## MEMO: WARUM KOMMEN DIE ÄNDERUNGEN NICHT AN

Warum das überhaupt funktioniert. mulle-test kann ja nur mulle-craft
aufrufen und weiss nix von den subprojects. Die sind aber wie "dependencies"
und werden dann dazugelinkt. Aber Änderungen kriegt man mit mulle-test clean
nicht rein, man muss mulle-sde craft machen.

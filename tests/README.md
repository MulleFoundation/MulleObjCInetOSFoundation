# How to run tests in Linux

```
cd ..
mulle-bootstrap clean
mulle-bootstrap build -c Debug
mulle-bootstrap install `pwd`

cd build
cmake -DCMAKE_INSTALL_PREFIX="`pwd`/.." -DCMAKE_BUILD_TYPE=Debug ..
make install
cd ../tests
./run-all-tests.sh
```

## Memo

> `sudo update-alternatives --install /usr/bin/lldb-server lldb-server /usr/bin/lldb-server-3.8 100`
> use this to fix
> preinstalled lldb on ubuntu

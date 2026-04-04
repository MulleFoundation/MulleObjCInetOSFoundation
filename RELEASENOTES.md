### 0.20.8







* Relocate the +dependencies provider: dependency declarations now live on MulleObjCDeps instead of MulleObjCLoader — **BREAKING**: callers expecting [MulleObjCLoader dependencies] must use MulleObjCDeps (or adapt).
* Regenerate reflect metadata to use objc-deps.inc and update exported/imported headers accordingly.
* Silence unused-parameter warnings in NSData+NSURL and NSURL+Filesystem (no behavioral change).

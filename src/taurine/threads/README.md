# taurine.threads package

This package is meant to provide cross-target threads to Haxe.
It's built so most thread-related functions are no-ops on single threaded environments (which can also be emulated with the `TAURINE_NO_THREADS` flag), so thread-aware code can freely execute on single-threaded environments without any performance penalty.

It is not however meant to emulate threads on platforms that don't support it. So thread creation and other functions that are impossible to provide the same meaning in a single-threaded environment will emit a warning at compile-time, and will fail at runtime.

## The TAURINE_NO_THREADS flag
If you're using `taurine` through haxelib (via `-lib taurine`), and not using the `-D TAURINE_CUSTOM_THREAD=path.to.package` compiler flag, the thread implementation will be automatically detected for you, and `TAURINE_NO_THREADS` will automatically be defined if needed. Otherwise you may need to either define `-D TAURINE_NO_THREADS` yourself, or call `--macro taurine.compiler.Taurine.beforeCompile()`.

### TAURINE_CUSTOM_THREAD
If you want to replace the default implementation or use threads in a platform which threads aren't currently implemented, you may also define `-D TAURINE_CUSTOM_THREAD=some.path.to.package` from the haxe command-line. The same remark as the topic above goes here - this will only work if either you use taurine through haxelib or call the above `--macro` call.

The file system api is starting to take shape. Some problems are however still present and need to be solved to get this running:

== Synchronous vs Asynchronous apis
 * Asynchronous should be the default - as a synchronous operation + scheduling can be made asynchronous, but not the opposite. A synchronous api should however be present so simple programs may use the taurine API without having to restructure everything.
 * Asynchronous operations + scheduling should be as lightweight as possible. On linux, for example, we can safely say that an object action can be resumed after its event descriptor is selected. If we're inside an action loop, we may be able to drop the closure creation, for example.

== Windows vs Linux paths
 * The Node.js way to deal with paths bother me a little. It means that if we get a path on a windows machine, serialize it and unserialize it on a Linux machine, it will fail to understand the path. The same problem goes to path globbing, for example

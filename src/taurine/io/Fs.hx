package taurine.io;

/**
	This structure provides a jQuery-inspired interface designed to simplify and abstract file and file system path manipulation.
	The actual filesystem implementation is abstracted away, and protocol handling can be plugged in - so the same
	file system interface can be used over a variety of different implementations.

	The main principles behind this design are:
	 - each `Fs` object is a list and can represent zero, one, or more than one file system objects and paths.
	   - if more than one path is represented, toString() will automatically join them using Path.delimiter
	 - glob patterns can be used to build selectors that may impact on one or more file system object
	 - exceptions are only raised by the `ensure` method family or when explicitly documented so.
	   Operations on empty matches are gracefully ignored.
	 - an fs object can be converted to and from URIs; when unspecified, the `file` protocol is implied. This
	   also means that other protocol implementations can be plugged into fs handling - for example `ftp`
	 - an fs object will only touch the file system when needed. selecting operations can be performed without touching the file system.
	 - each protocol can implement its own caching strategy, and it should be configurable. A `sync` operation can be performed
	   in order to force a cache flush.
**/
abstract Fs(FsData)
{
}

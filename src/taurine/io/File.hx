package taurine.io;

/**
 * A lazy structure that represents a file or directory in the file system.
 * System calls are only made when needed, and they are cached until sync() is called.
 *
 * `Warning: Due to its lazy properties, it is not thread-safe.`
 * @author waneck
 */
abstract File(FileData) from FileData
{
	public inline function new(f:FileData)
	{
		this = f;
	}

	/**
	 * Any String describing a path may be automatically converted into a File object
	 */
	@:from public static inline function fromString(s:String):File
	{
		return new FileData(s);
	}


}

class FileData
{
	public var originalPath(default, null):String;
	public var absolute(default, null):Bool;
	public var exists(get, never):Bool;
	private var _exists:Null<Bool>;

	/**
	 * Creates a new File reference. The file may exist or not.
	 */
	public function new(path:String)
	{
		this.originalPath = path;
		this.absolute = Path.isAbsolute(path);
	}

	/**
	 * Forces a synchronization of the current reference with the file system.
	 * @return itself
	 */
	public function sync():FileData
	{
		return this;
	}

	private function get_exists():Bool
	{
		if (_exists == null)
		{
			sync();
		}

		return _exists;
	}


}

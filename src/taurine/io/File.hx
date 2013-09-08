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
	public var length(get,never):Int;
	public var originalPath(default, null):String;
	public var absolute(default, null):Bool;
	public var exists(get, never):Bool;
	private var _exists:Null<Bool>;

	/**
	 * Creates a new File reference. The file may exist or not.
	 */
	public function new(?root:FileData, path:String)
	{
		this.originalPath = path;
		this.absolute = Path.isAbsolute(path);
	}

	public static function root(path:String):FileData
	{
		return new FileData(path);
	}

	/**
	 * Forces a synchronization of the current reference with the file system.
	 * @return itself
	 */
	public function sync():FileData
	{
		return this;
	}

	//async
	public function children(?selector:String):FileData
	{
	}

	public function parent(?selector:String):FileData
	{
	}


	public function ensure(atLeast=1, ?atMost:Int):FileData
	{
	}

	public function single()
	{
	}

	public function next(?selector:String):FileData
	{
	}

	public function nextAll(?selector:String):FileData
	{
	}

	public function nextUntil(selector:String):FileData
	{
	}

	public function prev(?selector:String):FileData
	{
	}

	public function prevAll(?selector:String):FileData
	{
	}

	public function prevUntil(selector:String):FileData
	{
	}

	public function siblings(?selector:String):FileData
	{
	}

	public function find(selector:String):FileData
	{
	}

	public function size():Int
	{
	}

	public function each(fn:FileData->Void):FileData
	{
	}

	public function filter(fn:FileData->Bool):FileData
	{
	}


	public function is(selector:String):Bool
	{
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

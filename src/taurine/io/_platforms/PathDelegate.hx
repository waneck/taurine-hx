package taurine.io._platforms;

/**
 * Delegate to cope with runtime differences between different systems.
 * @author waneck
 */
class PathDelegate
{
	public var sep(default, null):String;
	public var delimiter(default, null):String;
	
	public function normalize(s:String):String
	{
		return throw "NI";
	}
	
	public function isAbsolute(path:String):Bool
	{
		return throw "NI";
	}
	
	public function join(paths:Array<String>):String
	{
		return throw "NI";
	}
	
	public function relative(from:String, to:String):String
	{
		return throw "NI";
	}
	
	/**
		Resolves `to` to an absolute path.
	 */
	public function resolve(to:Array<String>):String
	{
		return throw "NI";
	}
	
	public function splitPath(filename:String):Array<String>
	{
		return throw "NI";
	}
	
	public function dirname(path:String):String
	{
		var result = splitPath(path);
		var root = result[0], dir = result[1];
		
		if ((root == null || root == '') && (dir == null || dir == ''))
		{
			// No dirname whatsoever
			return '.';
		}
		
		if (dir != null)
		{
			// It has a dirname, strip trailing slash
			dir = dir.substr(0, dir.length - 1);
		}
		
		return root + dir;
	}
	
	public function extname(path:String):String
	{
		return splitPath(path)[3];
	}
	
	public function basename(path:String, ?ext:String):String
	{
		var f = splitPath(path)[2];
		// TODO: make this comparison case-insensitive on windows?
		if (ext != null && f.substr(-1 * ext.length) == ext) {
			f = f.substr(0, f.length - ext.length);
		}
		return f;
	}
	
	public function makeLong(path:String):String
	{
		return path;
	}
}
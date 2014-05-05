package taurine.io;
import taurine.io._unsafe.Path in UPath;

/**
	This module contains utilities for handling and transforming file paths.
	Unless noted, these methods perform only string transformations. The file system is not consulted to check whether paths are valid.

	A `null` path is interpreted as `.` on any function here
**/
@:dce abstract Path(Null<String>) from String
{
	@:extern inline public function new(p:String)
	{
		this = p;
	}

	@:extern inline public static var dot:Path = new Path(".");

	/**
		Creates a new Path object, allowing some extra syntax sugars:
		```
		path(a/b/c); // a/b/c
		path(a / b / c); // a/b/c
		path("a/b"/c); // a/b/c
		root(); // /
		root(a/b/c); // /a/b/c
		path(".."/a/b/c); // ../a/b/c
		root(".."); //warning: absolute path is going beyond root
		```

		In order to use real variables' content, one must use single quotes:
		```
		var someVar = "someVarContents";
		path('$someVar/b/c'); // someVarContents/b/c
		path('$someVar'/b/c); // someVarContents/b/c
		root('$someVar'/b/c); // /someVarContents/b/c
		```
	**/
	macro public static function path(expr:haxe.macro.Expr):haxe.macro.Expr.ExprOf<Path>
	{
	}

	/**
		Creates a new Path root.
		@see `path`
	**/
	macro public static function root(?expr:haxe.macro.Expr):haxe.macro.Expr.ExprOf<Path>
	{
	}

	/**
		This operator is defined so a warning is placed on `+` operations.
		Addition operators should be avoided as it's easy to write unsafe code. Take for example the following code:
		```
			function addPath(root:String, path:String)
			{
				return root + path;
			}
		```
		Its meaning depends if `root` has a trailing slash or if `path` is an absolute path.
		`taurine.io.Path` then expects string concatenation to be perfomed explicitly, either by using `stradd` or its operator `^`
	**/
	@:deprecated("The `+` operator is unsafe to concatenate paths. Please use either `/` for directories or the `stradd` function")
	@:op(A + B) public function depAdd(to:Path):Path
	{
		return this + to.toString();
	}

	/**
		Construct a combined path from two paths. If `p` is absolute, it is returned unchanged
		Example:
		```
			path("foo/../..") / "bar" // ../bar
			path("/absolute/path.ext") / "bar" // /absolute/path.ext/bar
			path("/absolute/path") / "/other/absolute/path" // /other/absolute/path
			path("foo/../..") / "/absolute/path" // /absolute/path
		```
	**/
	@:op(A / B) public function combine(p:Path):Path
	{
		if (p.isAbsolute() || this == "")
			return p;
		if (p.toString() == "")
			return this;

		return this + UPath.sep + p;
	}

	@:op(A ^ B) public function stradd(string:String):Path
	{
		return this + string;
	}

	@:extern inline public function isAbsolute():Bool
	{
		return UPath.isAbsolute(this);
	}

	@:extern inline public function dirname():Path
	{
		return UPath.dirname(this);
	}

	@:extern inline public function basename(?ext:String):Path
	{
		return UPath.basename(this,ext);
	}

	/**
		Return the extension of the path, from the last '.' to end of string in the last portion of the path.
		If there is no '.' in the last portion of the path or the first character of it is '.', then it returns an empty string.
	**/
	@:extern inline public function extname():String
	{
		return UPath.extname(this);
	}

	public function relative(to:Path):Path
	{
		return UPath.relative(this,to.toString());
	}

	@:extern inline public function normalize():Path
	{
		return UPath.normalize(this);
	}

	@:extern inline public function toString():String
	{
		return this == null ? "." : this;
	}

	/**
		Ensures `path` cannot escape the current directory.
	**/
	public function jail(path:Path):Path
	{
		return null;
	}

	public function isParentOf(path:Path):Bool
	{
		return false;
	}

	public function iterator():Iterator<String>
	{
		return null;
	}

	@:extern inline public function up():Path
	{
		return combine("..");
	}
}

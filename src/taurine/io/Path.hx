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
		Creates a new root Path.
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
	@:deprecated("The `+` operator is unsafe to concatenate paths. Please use either `/` for directories or the `stradd` function (operator `^`)")
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

	/**
		Returns the relative path between two paths.

		If `this` and `to` paths are either both absolute, or both relative, the relative path returned without having to consult
		the current working directory.
		If however one is absolute and the other is relative, the current working directory is used to transform the relative into
		an absolute path.
		If the current working directory isn't available - as it happens on some platforms (JavaScript, Flash) - the current working directory
		is assumed to be the root path
	**/
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
		Ensures `path` cannot escape the current `this` path.
		If `path` escapes the current path, the current path itself is returned

		Examples:
		```
			// absolute paths
			var jailpath = root(some/path);
			jailpath.jail('other/path'); // /some/path/other/path
			jailpath.jail('other/../path'); // /some/path/path
			jailpath.jail('../../'); // /some/path
			jailpath.jail('../other/path'); // /some/path
			jailpath.jail('../../some/path/other/path'); // /some/path/other/path
			jailpath.jail('../../some/oops/../path/other/path'); // /some/path/other/path

			// relative paths work also
			jailpath = dot;
			jailpath.jail('other/path'); // other/path
			jailpath.jail('other/../path'); // path
			jailpath.jail('../'); // .
			jailpath.jail('../..'); // .
			jailpath.jail('/absolute/path'); // .
		```
	**/
	public function jail(path:Path):Path
	{
		return null;
	}

	/**
		Tests whether `this` path is a parent of `path`.
		The same logic from `jail` applies to this function:
		 * If `this` is an absolute path and `path` is a relative, or if both are relative, this function will return whether `path` would escape `this`.
		 * If however both are absolute paths, this function will return if `this` is a parent of `path`
		 * If `this` is a relative path and `path` is absolute, it will always return `false`
	**/
	public function isParentOf(path:Path):Bool
	{
		return false;
	}

	/**
		Allows one to iterate over each part of a path.
		The path is always normalized before running
		Examples:
		```
			using Lambda;

			path('some/path/').array(); // ['some','path']
			path('/some/path').array(); // ['some','path']
			path('C:\\some\\path').array(); // ['C:','some','path']; // on Windows
		```
	**/
	public function iterator():Iterator<String>
	{
		return null;
	}

	/**
		Interprets current `this` path as a relative path, even if it's absolute.
		It works by discarding the absolute part of a path.
		Examples:
		```
			path('/some/path').asRelative(); // some/path
			path('C:\\some\\path').asRelative(); // some/path
			path('some/path').asRelative(); // some/path - unchanged

			var somePath = path('/a/root/path');
			var sandbox = path('./sandbox');
			var transformed = sandbox.jail(somePath.asRelative()); // sandbox/a/root/path
		```
	**/
	public function asRelative():Path
	{
		return null;
	}

	/**
		Interprets the current `this` path as an absolute path, even if it's relative.
		It's the same as combining a root '/' to the path
	**/
	@:extern inline public function asAbsolute():Path
	{
		return new Path('/') / this;
	}

	/**
		Returns a path that goes up one level. Same as thisPath / "..".
	**/
	@:extern inline public function up():Path
	{
		return combine("..");
	}
}

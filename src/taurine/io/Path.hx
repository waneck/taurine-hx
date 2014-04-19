package taurine.io;
import taurine.io._unsafe.Path in UPath;

/**
	This module contains utilities for handling and transforming file paths.
	All these methods perform only string transformations. The file system is not consulted to check whether paths are valid.

	A `null` path is interpreted as `.`, or the current path
**/
abstract Path(Null<String>) from String
{
	@:extern inline public function new(p:String)
	{
		this = p;
	}

	@:op(A / B) public function add(p:Path):Path
	{
		return p.isAbsolute() ? p : this + UPath.sep + p;
	}

	@:extern inline public function isAbsolute():Bool
	{
		UPath.isAbsolute(this);
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
		Return the extension of the path, from the last '.' to end of string in the last portion of the path. If there is no '.' in the last portion of the path or the first character of it is '.', then it returns an empty string.
		Examples:
	**/
	@:extern inline public function extname():String
	{
		return UPath.extname(this);
	}

	public function relative(to:Path):Path
	{
		return UPath.relative(this,to);
	}

	@:extern inline public function normalize():Path
	{
		return UPath.normalize(this);
	}

	@:to @:extern inline public function toString():String
	{
		return this == null ? "." : this;
	}
}

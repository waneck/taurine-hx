package taurine.io;
import taurine.io._platforms.PathDelegate;
import taurine.System;
// this code was ported from Node.JS 'path' library
// last sync at commit: https://github.com/joyent/node/commit/22c68fdc1dae40f0ed9c71a02f66e5b2c6353691

// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

/**
 * This module contains utilities for handling and transforming file paths.
 * Almost all these methods perform only string transformations. The file system is not consulted to check whether paths are valid.
 */
class Path
{
	private static var _path:PathDelegate;
	private static function path():PathDelegate
	{
		if (_path != null)
			return _path;
		else if (System.isWin)
			return _path = new taurine.io._platforms.win.Path();
		else
			return _path = new taurine.io._platforms.posix.Path();
	}

	/**
	 * The platform-specific file separator. '\\' or '/'.
	 */
	public static var sep(get, never):String;

	/**
	 * The platform-specific path delimiter, ; or ':'.
	 */
	public static var delimiter(get, never):String;

	private static inline function get_sep()
	{
		return path().sep;
	}

	private static inline function get_delimiter()
	{
		return path().delimiter;
	}

	/**
		Normalize a string path, taking care of '..' and '.' parts.

		When multiple slashes are found, they're replaced by a single one; when the path contains a trailing slash,
		it is preserved. On Windows backslashes are used.
	 */
	public static function normalize(s:String):String
	{
		return path().normalize(s);
	}

	public static function isAbsolute(p:String):Bool
	{
		return path().isAbsolute(p);
	}

	/**
		Join all arguments together and normalize the resulting path.

		Arguments must be strings. In v0.8, non-string arguments were silently ignored. In v0.10 and up, an exception is thrown.
	 */
	public static function join(paths:Array<String>):String
	{
		return path().join(paths);
	}

	/**
		Solve the relative path from from to to.

		At times we have two absolute paths, and we need to derive the relative path from one to the other. This is actually the reverse transform of path.resolve, which means we see that:

		path.resolve(from, path.relative(from, to)) == path.resolve(to)
		Examples:

		```
		path.relative('C:\\orandea\\test\\aaa', 'C:\\orandea\\impl\\bbb')
		// returns
		'..\\..\\impl\\bbb'

		path.relative('/data/orandea/test/aaa', '/data/orandea/impl/bbb')
		// returns
		'../../impl/bbb'
		```
	**/
	public static function relative(from:String, to:String):String
	{
		return path().relative(from, to);
	}

	/**
		Resolves `to` to an absolute path.
	 */
	public static function resolve(to:Array<String>):String
	{
		return path().resolve(to);
	}

	public static function splitPath(filename:String):Array<String>
	{
		return path().splitPath(filename);
	}

	/**
		Return the directory name of a path. Similar to the Unix `dirname` command.
	 */
	public static function dirname(p:String):String
	{
		return path().dirname(p);
	}

	/**
		Return the last portion of a path. Similar to the Unix basename command.

		```
		Example:

		path.basename('/foo/bar/baz/asdf/quux.html')
		// returns
		'quux.html'

		path.basename('/foo/bar/baz/asdf/quux.html', '.html')
		// returns
		'quux'
		```
	 */
	public static function basename(p:String, ?ext:String):String
	{
		return path().basename(p, ext);
	}

	/**
		Return the extension of the path, from the last '.' to end of string in the last portion of the path.
		If there is no '.' in the last portion of the path or the first character of it is '.', then it returns an empty string. Examples:
	**/
	public static function extname(p:String):String
	{
		return path().extname(p);
	}

	public static function makeLong(p:String):String
	{
		return path().makeLong(p);
	}

	public static function normalizeArray(parts:Array<String>, allowAboveRoot:Bool)
	{
		// if the path tries to go above the root, `up` ends up > 0
		var up = 0;
		var i = parts.length - 1;
		while(i >= 0)
		{
			var last = parts[i];
			if (last == '.') {
				parts.splice(i, 1);
			} else if (last == '..') {
				parts.splice(i, 1);
				up++;
			} else if (up != 0) {
				parts.splice(i, 1);
				up--;
			}
			i--;
		}

		// if the path is allowed to go above the root, restore leading ..s
		if (allowAboveRoot)
		{
			while (up-- > 0)
			{
				parts.unshift('..');
			}
		}

		return parts;
	}
}

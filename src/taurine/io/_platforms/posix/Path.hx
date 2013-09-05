package taurine.io._platforms.posix;
import taurine.io._platforms.PathDelegate;
import taurine.System;

/**
 * ...
 * @author waneck
 */
class Path extends PathDelegate
{
	var splitPathRe:EReg;

	public function new()
	{
		splitPathRe = ~/^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
		this.sep = '/';
		this.delimiter = ':';
	}

	public override function splitPath(filename:String):Array<String>
	{
		if (!splitPathRe.match(filename))
			throw 'Invalid path: $filename';
		return [splitPathRe.matched(1), splitPathRe.matched(2), splitPathRe.matched(3), splitPathRe.matched(4)];
	}

	override public function resolve(to:Array<String>):String
	{
		var resolvedPath = '',
			resolvedAbsolute = false;

		var i = to.length - 1;
		while (i >= -1 && !resolvedAbsolute)
		{
			var path = (i >= 0) ? to[i] : System.cwd();
			i--;
			if (path == '' || path == null)
			{
				continue;
			}

			resolvedPath = path + '/' + resolvedPath;
			resolvedAbsolute = path.charAt(0) == '/';
		}

		// At this point the path should be resolved to a full absolute path, but
		// handle relative paths to be safe (might happen when process.cwd() fails)

		// Normalize the path
		resolvedPath = taurine.io.Path.normalizeArray(resolvedPath.split('/').filter(function(p) {
		  return p != null && p != '';
		}), !resolvedAbsolute).join('/');

		var ret = ((resolvedAbsolute ? '/' : '') + resolvedPath);
		return ret != '' ? ret : '.';
	}

	override public function normalize(path:String):String
	{
		var isAbsolute = isAbsolute(path),
			trailingSlash = path.substr(-1) == '/';

		// Normalize the path
		path = taurine.io.Path.normalizeArray(path.split('/').filter(function(p) {
			return p != null && p != '';
		}), !isAbsolute).join('/');

		if ((path == null || path == '') && !isAbsolute)
		{
			path = '.';
		}

		if (path != null && path != '' && trailingSlash)
		{
			path += '/';
		}

		return (isAbsolute ? '/' : '') + path;
	}

	override public function isAbsolute(path:String):Bool
	{
		return path.charAt(0) == '/';
	}

	override public function join(paths:Array<String>):String
	{
		paths = paths.filter(function(s) return s != null && s.length > 0);
		return normalize(paths.join('/'));
	}

	override public function relative(from:String, to:String):String
	{
		from = resolve([from]).substr(1);
		to = resolve([to]).substr(1);

		function trim(arr:Array<String>)
		{
			var start = 0, len = arr.length;
			while (start < len)
			{
				if (arr[start] != null && arr[start] != '')
					break;
				start++;
			}

			var end = arr.length - 1;
			while (end >= 0)
			{
				if (arr[end] != null && arr[end] != '')
					break;
				end--;
			}

			if (start > end) return [];
			return arr.slice(start, end - start + 1);
		}

		var fromParts = trim(from.split('/'));
		var toParts = trim(to.split('/'));

		var length = Std.int(Math.min(fromParts.length, toParts.length));
		var samePartsLength = length;
		for (i in 0...length)
		{
		  if (fromParts[i] != toParts[i])
		  {
				samePartsLength = i;
				break;
		  }
		}

		if (samePartsLength == 0)
			return to;

		var outputParts = [];
		for (i in samePartsLength...fromParts.length)
		{
		  outputParts.push('..');
		}

		outputParts = outputParts.concat(toParts.slice(samePartsLength));

		return outputParts.join('/');
	}


}

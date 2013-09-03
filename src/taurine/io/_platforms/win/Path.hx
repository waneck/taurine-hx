package taurine.io._platforms.win;
import taurine.io._platforms.PathDelegate;
import taurine.System;

class Path extends PathDelegate
{
	// Regex to split a windows path into three parts: [*, device, slash,
	// tail] windows-only
	var splitDeviceRe:EReg;

	// Regex to split the tail part of the above into [*, dir, basename, ext]
	var splitTailRe:EReg;
	
	public function new()
	{
		splitDeviceRe = ~/^([a-zA-Z]:|[\\\/]{2}[^\\\/]+[\\\/]+[^\\\/]+)?([\\\/])?([\s\S]*?)$/;
		splitTailRe = ~/^([\s\S]*?)((?:\.{1,2}|[^\\\/]+?|)(\.[^.\/\\]*|))(?:[\\\/]*)$/;
		this.sep = '\\';
		this.delimiter = ';';
	}
	
	override public function resolve(to:Array<String>):String 
	{
		var resolvedDevice = '',
        resolvedTail = '',
        resolvedAbsolute = false,
		isUnc = false;

		var i = to.length - 1;
		while (i >= -1)
		{
			var path;
			if (i >= 0) {
				path = to[i];
			} else if (resolvedDevice == null || resolvedDevice == '' ) {
				path = System.cwd();
			} else {
				// Windows has the concept of drive-specific current working
				// directories. If we've resolved a drive letter but not yet an
				// absolute path, get cwd for that drive. We're sure the device is not
				// an unc path at this points, because unc paths are always absolute.
				path = System.env['=' + resolvedDevice];
				// Verify that a drive-local cwd was found and that it actually points
				// to our drive. If not, default to the drive's root.
				if (path == null || path == "" || path.substr(0, 3).toLowerCase() != resolvedDevice.toLowerCase() + '\\') 
				{
					path = resolvedDevice + '\\';
				}
			}
			i--;

			// Skip empty and invalid entries
			if (path == null || path == "")
			{
				continue;
			}

			if (!splitDeviceRe.match(path))
				throw 'Invalid path: $path';
			var device = splitDeviceRe.matched(1),
			  isAbsolute = isAbsolute(path),
			  tail = splitDeviceRe.matched(3);
			isUnc = ( device != null ? device.charAt(1) != ':' : false);

			if (device != null && device != '' &&
			  resolvedDevice != null && resolvedDevice != '' &&
			  device.toLowerCase() != resolvedDevice.toLowerCase()) 
			{
				// This path points to another device so it is not applicable
				continue;
			}

			if (resolvedDevice == null || resolvedDevice == '') 
			{
				resolvedDevice = device;
			}

			if (!resolvedAbsolute) {
				resolvedTail = tail + '\\' + resolvedTail;
				resolvedAbsolute = isAbsolute;
			}

			if (resolvedDevice != null && resolvedDevice != '' && resolvedAbsolute) 
			{
				break;
			}
		}

		// Convert slashes to backslashes when `resolvedDevice` points to an UNC
		// root. Also squash multiple slashes into a single one where appropriate.
		if (isUnc) 
		{
			resolvedDevice = normalizeUNCRoot(resolvedDevice);
		}

		// At this point the path should be resolved to a full absolute path,
		// but handle relative paths to be safe (might happen when process.cwd()
		// fails)

		// Normalize the tail path

		function f(p) {
		  return p != null && p != '';
		}

		resolvedTail = taurine.io.Path.normalizeArray(~/[\\\/]+/g.split(resolvedTail).filter(f),
									  !resolvedAbsolute).join('\\');

		var ret = (resolvedDevice + (resolvedAbsolute ? '\\' : '') + resolvedTail);
		return ret != '' ? ret : '.';
	}
	
	// Function to split a filename into [root, dir, basename, ext]
	// windows version
	public override function splitPath(filename:String):Array<String> 
	{
		// Separate device+slash from tail
		var device = '', tail = '';
		if (!splitDeviceRe.match(filename))
			throw "Invalid filename structure: " + filename;
		{
			var m1 = splitDeviceRe.matched(1);
			var m2 = splitDeviceRe.matched(2);
			var m3 = splitDeviceRe.matched(3);
			if (m1 == null) m1 = '';
			if (m2 == null) m2 = '';
			if (m3 == null) m3 = '';
			
			device = m1 + m2;
			tail = m3;
		}
		
		// Split the tail into dir, basename and extension
		var dir = null, basename = null, ext = null;
		if (!splitTailRe.match(tail))
			throw "Invalid filename structure: " + tail;
		dir = splitTailRe.matched(1);
		basename = splitTailRe.matched(2);
		ext = splitTailRe.matched(3);
		
		if (dir == null) dir = '';
		if (basename == null) basename = '';
		if (ext == null) ext = '';
		
		return [device, dir, basename, ext];
	}
	
	function normalizeUNCRoot(device:String)
	{
		return '\\\\' + ~/^[\\\/]+/.replace(~/[\\\/]+/g.replace(device, '\\'), '');
	}
	
	override public function normalize(path:String):String 
	{
		if (!splitDeviceRe.match(path))
			throw 'Invalid path: $path';
		
		var device = splitDeviceRe.matched(1),
			isUnc = device != null && device != '' && device.charAt(1) != ':',
			isAbsolute = isAbsolute(path),
			tail = splitDeviceRe.matched(3),
			trailingSlash = ~/[\\\/]$/.match(tail);

		if (device == null)
			device = '';
		// If device is a drive letter, we'll normalize to lower case.
		if (device != null && device.charAt(1) == ':') {
			device = device.charAt(0).toLowerCase() + device.substr(1);
		}

		// Normalize the tail path
		tail = taurine.io.Path.normalizeArray(~/[\\\/]+/g.split(tail).filter(function(p) {
			return p != null && p != '';
		}), !isAbsolute).join('\\');

		if ((tail == null || tail == '') && !isAbsolute) {
			tail = '.';
		}
		if ((tail != null && tail != '') && trailingSlash) {
			tail += '\\';
		}

		// Convert slashes to backslashes when `device` points to an UNC root.
		// Also squash multiple slashes into a single one where appropriate.
		if (isUnc) {
			device = normalizeUNCRoot(device);
		}

		return device + (isAbsolute ? '\\' : '') + tail;
	}
	
	override public function isAbsolute(path:String):Bool 
	{
		if (!splitDeviceRe.match(path))
			throw 'Invlaid path: $path';
		var device = splitDeviceRe.matched(1),
			isUnc = device != null && device != '' && device.charAt(1) != ':';
		// UNC paths are always absolute
		var m2 = splitDeviceRe.matched(2);
		return (m2 != null && m2 != '') || isUnc;
	}
	
	override public function join(paths:Array<String>):String 
	{
		paths = paths.filter(function(s) return s != null && s.length != 0);
		var joined = paths.join('\\');

		// Make sure that the joined path doesn't start with two slashes, because
		// normalize() will mistake it for an UNC path then.
		//
		// This step is skipped when it is very clear that the user actually
		// intended to point at an UNC path. This is assumed when the first
		// non-empty string arguments starts with exactly two slashes followed by
		// at least one more non-slash character.
		//
		// Note that for normalize() to treat a path as an UNC path it needs to
		// have at least 2 components, so we don't filter for that here.
		// This means that the user can use join to construct UNC paths from
		// a server name and a share name; for example:
		//   path.join('//server', 'share') -> '\\\\server\\share\')
		if (paths[0] != null && !~/^[\\\/]{2}[^\\\/]/.match(paths[0])) {
			joined = ~/^[\\\/]{2,}/g.replace(joined, '\\');
		}

		return normalize(joined);
	}
	
	// path.relative(from, to)
	// it will solve the relative path from 'from' to 'to', for instance:
	// from = 'C:\\orandea\\test\\aaa'
	// to = 'C:\\orandea\\impl\\bbb'
	// The output of the function should be: '..\\..\\impl\\bbb'
	// windows version
	override public function relative(from:String, to:String):String 
	{
		from = resolve([from]);
		to = resolve([to]);

		// windows is not case sensitive
		var lowerFrom = from.toLowerCase();
		var lowerTo = to.toLowerCase();

		function trim(arr:Array<String>) {
		  var start = 0, len = arr.length;
		  while (start < len)
		  {
			  if (arr[start] != '') break;
			  start++;
		  }

		  var end = arr.length - 1;
		  while (end >= 0)
		  {
			  if (arr[end] != '') break;
			  end--;
		  }

		  if (start > end) return [];
		  return arr.slice(start, end - start + 1);
		}

		var toParts = trim(to.split('\\'));

		var lowerFromParts = trim(lowerFrom.split('\\'));
		var lowerToParts = trim(lowerTo.split('\\'));

		var length = Std.int(Math.min(lowerFromParts.length, lowerToParts.length));
		var samePartsLength = length;
		var i = 0;
		while(i < length)
		{
		  if (lowerFromParts[i] != lowerToParts[i]) {
			samePartsLength = i;
			break;
		  }
		  i++;
		}

		if (samePartsLength == 0) {
		  return to;
		}

		var outputParts = [];
		var i = samePartsLength;
		while (i < lowerFromParts.length)
		{
		  outputParts.push('..');
		  i++;
		}

		outputParts = outputParts.concat(toParts.slice(samePartsLength));

		return outputParts.join('\\');
	}
	
	override public function makeLong(path:String):String 
	{
		if (path == null || path == '')
			return '';
		var resolvedPath = resolve([path]);
		
		if (~/^[a-zA-Z]:\\/.match(resolvedPath)) {
			// path is local filesystem path, which needs to be converted
			// to long UNC path.
			return '\\\\?\\' + resolvedPath;
		} else if (~/^\\\\[^?.]/.match(resolvedPath)) {
			// path is network UNC path, which needs to be converted
			// to long UNC path.
			return '\\\\?\\UNC\\' + resolvedPath.substring(2);
		}

		return path;
	}
}
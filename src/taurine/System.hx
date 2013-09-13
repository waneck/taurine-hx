package taurine;

/**
 * Standard System-bound utilities
 * @author waneck
 */
class System
{

	@:isVar public static var isWin(get, null):Bool;
	@:isVar public static var isMac(get, null):Bool;
	@:isVar public static var isUnix(get, null):Bool;

	public static var env(get, null):Map<String,String>;

	private static var __init = false;

	private static function get_env()
	{
#if sys
		if (env == null)
			return env = Sys.environment();
		return env;
#else
		if (env == null)
			return env = new Map();
		return env;
#end
	}

	private static function get_isWin()
	{
		if (__init) return isWin;
		init();
		return isWin;
	}

	private static function get_isMac()
	{
		if (__init) return isMac;
		init();
		return isMac;
	}

	private static function get_isUnix()
	{
		if (__init) return isUnix;
		init();
		return isUnix;
	}

	static function init()
	{
#if sys
		var name = Sys.systemName().toLowerCase();
		if (name.indexOf("windows") != -1)
		{
			isMac = isUnix = false;
			isWin = true;
		} else if (name.indexOf("mac") != -1) {
			isMac = isUnix = true;
			isWin = false;
		} else {
			isUnix = true;
			isWin = isMac = false;
		}
#end
		__init = true;
	}

	public static function cwd()
	{
		#if sys
		return Sys.getCwd();
		#else
		return throw "Not Implemented";
		#end
	}
}

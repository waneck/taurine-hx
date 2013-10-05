package taurine.async;

#if !cpp
#if (java || flash9)
//static targets - achieve best performance
@:generic class Task<T>

#elseif cs
//C# has @:generic built into the JIT compiler
class Task<T>

#else
//untyped targets have no benefit from it to be a class;
//rather, it will only incur on extra uneeded information
typedef Task<T> =

#end
{
	/**
		`hasNext()` must be called for the generator to work correctly.
		Also calling it multiple times will skip values - even without calling next()
	 **/
	function hasNext():Bool;
	function next():T;
	/**
		Report an exception to the action
	**/
	function exception(e:Dynamic):Void;
}
#else
//C++ already has its own fast iterator class
class Task<T> extends cpp.FastIterator<T>
{
	public function exception(e:Dynamic):Void;
}

#end

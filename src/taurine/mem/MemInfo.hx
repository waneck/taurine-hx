package taurine.mem;

class MemInfo
{
	/**
		Returns the buffer length if it was set.

		If the buffer has no length set, returns `0`
		If the buffer's length is too big to store in an `Int`, returns a negative value
	**/
	public var length(default,null):Int;
	public var length64(default,null):Int64;

	/**
		Sets the buffer length if it wasn't set yet.

		@throws `UnsafeOperation` if the buffer length was already set and has a different value than `len`
	**/
	public function setLength(newLen:Int):Void
	{
	}

	public function setLength64(newLen:Int64):Void
	{
	}
}

package taurine.mem;

/**
	Represents the accessor to a memory chunk.
**/
class MemChunk implements taurine.Disposable.IDisposable
{
	private var info:MemInfo;

	/**
		Returns the buffer length
		If the buffer's length is too big to store in an `Int`, returns a negative value
	**/
	public var length(default,null):Int;
	public var length64(default,null):Int64;

	private function new(info,len64)
	{
		if (info == null)
			throw "Null argument";
		this.info = info;
		this.info.acquire();
	}

	/**
		Creates a new view starting at offset `bytesOffset`.

		If `newLength` is set, also sets the length of the view. Otherwise `this.length - bytesOffset` will be used.

		@throws `OutOfBounds` error if `bytesOffset` is greater than `this.length` or if `bytesOffset + newLength` is greater than `this.length`
		@throws `UnsafeOperation` if `this` has no `length` set.
	**/
	public function view(bytesOffset:Int, ?newLength:Int):MemoryChunk
	{
	}

	public function view64(bytesOffset:Int64, ?newLength:Int64):MemoryChunk
	{
	}

	/**
		Expands a view to the whole containing memory chunk address. If `this` memory chunk is not a view, it will return itself.
	**/
	public function expand():MemoryChunk
	{
	}

	/**
		Returns `true` if `this` memory chunk was derived from a `view` operation
	**/
	public function isView():Bool
	{
	}

	/**
		Releases current memory chunk use. Each MemChunk must be disposed independently, even if they point to the same memory location.
	**/
	public function dispose()
	{
		this.info.release();
		this.info = null;
		this.length = 0;
		this.length64 = 0;
	}
}

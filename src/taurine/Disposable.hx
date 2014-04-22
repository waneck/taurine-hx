package taurine;

/**
	Provides a mechanism for releasing resources.

	The `Disposable` abstract wraps an `IDisposable` interface in a null-safe way.
	A `Void->Void` function can be converted into `Disposable` automatically.
**/
@:dce abstract Disposable(IDisposable) from IDisposable to IDisposable
{
	@:extern inline public function new(d:IDisposable)
	{
		this = d;
	}

	@:from public static function fromFunc(fn:Void->Void):Disposable
	{
		return new FromFunc(fn);
	}

	@:from public static function fromCloseable(closeable:{ function close():Void; }):Disposable
	{
		return new FromCloseable(closeable);
	}

	@:extern inline public function dispose():Void
	{
		if (this != null) this.dispose();
	}
}

/**
	The actual `IDisposable` interface - as wrapped by the `Disposable` abstract.
**/
interface IDisposable
{
	function dispose():Void;
}

@:dce private class FromCloseable implements IDisposable
{
	var wrapped:{ function close():Void; };
	public function new(wrapped)
	{
		this.wrapped = wrapped;
	}

	public function dispose():Void
	{
		if (this.wrapped != null)
			this.wrapped.close();
	}
}

@:dce private class FromFunc implements IDisposable
{
	var fn:Void->Void;

	public function new(fn:Void->Void)
	{
		this.fn = fn;
	}

	public function dispose()
	{
		if (fn != null)
			fn();
	}
}

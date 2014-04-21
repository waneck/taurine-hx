package taurine.react;
import taurine.Disposable;

/**
	`Source` defines a provider for push-based notifications.
**/
@:dce abstract Source<T>(ISource<T>) from ISource<T> to ISource<T>
{
	@:extern inline public function subscribe(listener:Listener<T>):Disposable
	{
		return this.subscribe(listener);
	}

	@:from @:extern inline public static function fromFunc<T>(fn:Listener<T>->Disposable):Source<T>
	{
		return new FromFunc(fn);
	}

	/**
		Wraps a `Source` type so it hides its internal implementation details
	**/
	@:extern inline public function wrap():Source<T>
	{
		if (Std.is(this, SourceWrap))
			return this;
		else
			return new SourceWrap(this);
	}
}

interface ISource<T>
{
	function subscribe(listener:Listener<T>):Disposable;
}

@:dce private class FromFunc<T> implements ISource<T>
{
	var fn:Listener<T>->Disposable;

	public function new(fn)
	{
		this.fn = fn;
	}

	public function subscribe(listener:Listener<T>):Disposable
	{
		return fn(listener);
	}
}

@:dce private class SourceWrap<T> implements ISource<T>
{
	var wrapped:Source<T>;

	public function new(w)
	{
		this.wrapped = w;
	}

	public function subscribe(listener:Listener<T>):Disposable
	{
		return wrapped.subscribe(listener);
	}
}

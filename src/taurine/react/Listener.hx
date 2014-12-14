package taurine.react;

/**
	Provides a mechanism for receiving push-based notifications
**/
@:dce abstract Listener<T>(IListener<T>) from IListener<T> to IListener<T>
{
	@:extern inline public function new(t:IListener<T>)
	{
		this = t;
	}

	@:extern inline public function onNext(value:T):Void
	{
		this.onNext(value);
	}

	@:extern inline public function onCompleted():Void
	{
		this.onCompleted();
	}

	@:extern inline public function onError(exception:Dynamic):Void
	{
		this.onError(exception);
	}
}

interface	IListener<T>
{
	function onNext(value:T):Void;
	function onCompleted():Void;
	function onError(exception:Dynamic):Void;
}

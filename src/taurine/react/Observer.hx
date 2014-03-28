package taurine.react;

abstract Observer<T>(IObserver<T>) from IObserver<T>
{
	@:extern inline public function new(t)
	{
		this = t;
	}
}

interface IObserver<T>
{
	function onCompleted():Void;
	function onError(error:Dynamic):Void;
	function onNext(next:T):Void;
}

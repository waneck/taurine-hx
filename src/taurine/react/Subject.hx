package taurine.react;
import taurine.Disposable;
import taurine.ds.Stack;
import taurine.react.Source;
import taurine.react.Listener;

class Subject<T> implements ISource<T> implements IListener<T>
{
	private var listeners:Stack<Listener<T>>;
	public function new()
	{
		this.listeners = new Stack();
	}

	public function empty():Bool
	{
		return listeners.peek() == null;
	}

	public function subscribe(listener:Listener<T>):Disposable
	{
		return listeners.push(listener);
	}

	public function onNext(val:T):Void
	{
		listeners.iter(function(l)
		{
			l.onNext(val);
		});
	}

	public function onCompleted():Void
	{
		listeners.iter(function(l)
		{
			l.onCompleted();
		});
	}

	public function onError(exc:Dynamic):Void
	{
		listeners.iter(function(l)
		{
			l.onError(exc);
		});
	}
}

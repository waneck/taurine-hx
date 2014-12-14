package taurine.react;
import taurine.Disposable;
import taurine.ds.Stack;
import taurine.react.Source;
import taurine.react.Listener;
import taurine.react.Errors;

class Subject<T> implements ISubject<T> implements IDisposable
{
	private var listeners:Stack<Listener<T>>;
	private var disposed:Bool;
	private var stopped:Bool;
	private var exception:Dynamic;

	public function new()
	{
		this.listeners = new Stack();
	}

	public function empty():Bool
	{
		var l = listeners;
		return l == null || l.peek() == null;
	}

	public function subscribe(listener:Listener<T>):Disposable
	{
		checkDisposed();
		var l = listeners;

		return listeners.push(listener);
	}

	public function onNext(val:T):Void
	{
		checkDisposed();
		if (!stopped)
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
		if (exc == null)
			throw ExceptionIsNull;
		listeners.iter(function(l)
		{
			l.onError(exc);
		});
		stopped = true;
		exception = exc;
	}

	public function dispose()
	{
		disposed = true;
		this.listeners = null;
	}

	inline private function checkDisposed()
	{
		if (disposed)
			throw SourceDisposed;
	}
}

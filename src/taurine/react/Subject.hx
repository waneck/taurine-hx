package taurine.react;
import taurine.Disposable;
import taurine.react.Source;
import taurine.react.Listener;

class Subject<T> implements ISource<T> implements IListener<T>
{
	public function new()
	{
		this.listeners = new Node(null);
	}

	public function subscribe(listener:Listener<T>):Disposable
	{
	}
}

class Node<T> implements IDisposable
{
	var next:Node<T>;
	var last:Node<T>;
	public var value(default,null):T;

	public function new(value:T)
	{
		this.value = value;
	}


}

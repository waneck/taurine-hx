package taurine.react;
import taurine.Disposable;

/**
	Represents a value that changes over time.
	Any observer that subscribe to the subject will receive the last value and all subsequent notifications
**/
class Property<T> extends Subject<T> implements IDisposable
{
	public var value(default,null):T;
}

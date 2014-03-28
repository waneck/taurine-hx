package taurine.react;

interface IObservable<T>
{
	function subscribe(observer:Observer<T>):Disposer;
}

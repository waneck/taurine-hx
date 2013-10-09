package taurine.async._internal;

abstract IteratorHelper<T>(Iterator<T>) from Iterator<T> to Iterator<T>
{
	@:extern inline public function next():T
	{
		return this.next();
	}

	@:extern inline public function hasNext():Bool
	{
		return this.hasNext();
	}

	@:from @:extern inline public static function fromIterable(i:Iterable<T>):IteratorHelper<T>
	{
		return i.iterator();
	}

	@:extern inline public static function convert<T>(i:IteratorHelper<T>):Iterator<T>
	{
		return i;
	}
}

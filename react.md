## What I think should work

### From deprecating observer pattern:
```haxe
	var down = @await mouseDown;
	@yield MoveTo(down);
	while (true)
	{
		var move = @await mouseMove;
		var up = @peek mouseUp;
		if (up != null) break;
		@yield LineTo(move);
	}
	@yield Finish;

	: Observable<LineDef>
```

Second version:
```haxe
	var down = @await mouseDown;
	@yield MoveTo(down);
	try
	{
		while(true)
		{
			var move = @await mouseMove;
			@yield LineTo(move);
		}
	}
	catch(e:Cancel) {
		// example only - rethrow
		throw e;
	}
	catch(e:Stop) {
		@yield Finish;
	}
```

#### problems derived from this code
 - @peek is not well defined. An event message shouldn't be queued by default
 - let's say that mouseUp is actually a <Void> event (so e.g. a key can also escape the path). How to listen to two different events and still maintain a type-safe interface?
	- easy way: create a new Observer object for each object

### From imnotcrond:
```haxe
	function main()
	{
		while(true)
		{
			var c = @await (file1,file2,recursiveDir,filePattern,gitRepo);
			runCommand(x);
		}
	}

	@async function filePattern(dir:Directory, pattern:Glob):Observable<File>
	{
		var modified:Observable<File> = dir.modified(flags);
		while (true)
		{
			var file = @await modified;
			if (pattern.match(file))
				@yield file;
		}
	}

```

#### problems derived from this code
	- a file pattern is an observable; which in its turn will receive the actual event, and only pass through 

## In general
 - Maybe we can come up with better naming than Observable / Observer. ( Source / Listener, Publisher / Subscriber ?)

## Possible implementation

```haxe
class {
	function onNext(dyn:Dynamic)
	{
		while(true)
		{
			switch(state++)
			{
				case 0:
					md_dispose = mouseDown.listen(this);
					return;
				case 1:
					// how to return??
					md_dispose.dispose();
					listener.onNext( MoveTo(dyn) );
				case 2:
					move_dispose = mouseMove.listen(this);
					return;
				case 3:
					move_dispose.dispose();
					listener.onNext( LineTo(dyn) );
					state = 2;
				default:
					break;
			}
		}
	}

	function onError(dyn:Dynamic)
	{
		if (Std.is(dyn, Stop))
		{
			listener.onNext( Finish );
			listener.onFinish();
		}
	}
}
```

### Outlook
	- See if the interrupt nature of exceptions can be well fitted in this scenario. E.g. an exception thrown while actually executing code, and not in yielded state
	- Having to listen and dispose the listener after each call is very wasteful. Specially on immutable sources. It might as well be wrong, if the source is another reactor (2)
	-

### Thoughts on (2)
 - Depending on how we implement an immutable reactor, we may really have a wrong result. Example:

```haxe
	@async function test():Source<Int>
	{
		@yield 1;
		@yield 2;
		@yield 3;
		@yield 4;
	}
```
First implementation:
```haxe
	class TestImpl 
	{
		var listener:Listener<Int>;
		function new(l) listener = l;
		function onNext(_)
		{
			switch(state++)
			{
				case 0:
					listener.onNext(1);
					return;
				case 1:
					listener.onNext(2);
					return;
				case 2:
					listener.onNext(3);
					return;
				case 3:
					listener.onNext(4);
					return;
				deafult:
					listener.onCompleted();
			}
		}
	}

	function test()
	{
		return Source.create(function (l:Listener) return new TestImpl(l));
	}
```

This implementation will create a new Source for each listener, which will obviously not generate the expected results if we listen and dispose after each @await
We could change the way to deal with that, but still there is a problem with some cold observable implementations lurking if we adopt the listen/dispose after each @await

possible solution:
```haxe
	var down = @await mouseDown;
	@yield MoveTo(down);
	try
	{
		@asyncFor (move in mouseMove)
		{
			@yield LineTo(move);
		}
	}
	catch(e:Cancel) {
		// example only - rethrow
		throw e;
	}
	catch(e:Stop) {
		@yield Finish;
	}
```



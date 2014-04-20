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
 - Maybe we can come up with better naming than Observable / Observer. ( Source / Listener ?)

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

package taurine.threads;

typedef MutexData =
#if TAURINE_NO_THREADS
	SingleThreadedMutex;
#elseif TAURINE_CUSTOM_THREAD
	CustomMutex;
#elseif neko
	neko.vm.Mutex;
#elseif cpp
	cpp.vm.Mutex;
#elseif java
	java.vm.Mutex;
#elseif cs
	cs.vm.Mutex;
#else
	See_readme_md_file_at_taurine_threads_dir;
#end

/**
	A `Mutex` can be used to acquire a temporary lock to access a resource. The mutex must always be release by the owner thread
**/
@:dce abstract Mutex(MutexData) from MutexData to MutexData
{
	/**
		Creates a new released `Mutex` object
	**/
	@:extern inline public function new()
	{
		this = new MutexData();
	}

	/**
		Acquire the mutex if it is free or wait until it is available. The same thread can acquire several times the same mutex, but it must release it
		as many times it has been acquired
	**/
	@:extern inline public function acquire():Void
	{
		this.acquire();
	}

	/**
		Release a mutex that has been acquried by the current thread. If the current thread does not own the mutex, an exception will be thrown
	**/
	@:extern inline public function release():Void
	{
		this.release();
	}

	/**
		Try to acquire the mutex. Returns true if it did acquire or false if it's already locked by another thread
	**/
	@:extern inline public function tryAcquire():Bool
	{
		return this.tryAcquire();
	}

	/**
		Allows a block to be passed to this `Mutex` object, which will be executed in a synchronized manner.
		This function executes in a `finally`-like context and is the safest way to avoid deadlocks.

		Example:
		```
			var obj = { mutex: new Mutex(), number: 0 };
			function safeIncrement()
			{
				obj.m.synchronized({
					obj.number++;
				});
			}
		```
	**/
	macro public function synchronized(ethis:haxe.macro.Expr, doExpr:haxe.macro.Expr):haxe.macro.Expr
	{
		//TODO change name?
		if (haxe.macro.Context.defined("TAURINE_NO_THREADS"))
		{
			return doExpr;
		} else {
			return taurine.threads._internal.LockHelper.transformLock(ethis,doExpr, false);
		}
	}
}

#if TAURINE_NO_THREADS
class SingleThreadedMutex
{
	public function new()
	{
	}

	/**
		Since there should only be one thread when on a single-threaded context,
		`acquire` is a no-op
	**/
	@:extern inline public function acquire()
	{
	}

	/**
		Since there should only be one thread when on a single-threaded context,
		`release` is a no-op
	**/
	@:extern inline public function release()
	{
	}

	/**
		Since there should only be one thread when on a single-threaded context,
		`tryAcquire` is a no-op
	**/
	@:extern inline public function tryAcquire():Bool
	{
		return true;
	}
}
#end

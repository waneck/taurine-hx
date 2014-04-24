package taurine.threads;

/**
	Reentrant lock implementation. Begins in locked state, and can be released several times.
	For each time it is released, it can be acquired as many times.
**/
typedef Lock =
#if TAURINE_NO_THREADS
	SingleThreadedLock;
#elseif TAURINE_CUSTOM_THREAD
	CustomLock;
#elseif neko
	neko.vm.Lock;
#elseif cpp
	cpp.vm.Lock;
#elseif java
	java.vm.Lock;
#elseif cs
	cs.vm.Lock;
#else
	See_readme_md_file_at_taurine_threads_dir;
#end

#if TAURINE_NO_THREADS
/**
	A single-threaded reentrant lock. Holds the same mechanism as the multi-threaded implementation,
	but will throw an exception if it would block.
**/
class SingleThreadedLock
{
	private var count:Int;

	/**
		Creates a new lock, which is initially locked
	**/
	public function new()
	{
		this.count = 0;
	}

	/**
		Release a lock. If a lock is released several times, it can be acquired as many times.
	**/
	public function release():Void
	{
		count--;
	}

	/**
		Acquire a lock if possible.
		If no lock count is available, it will either return failure (`false`) in case `timeout` is different from `null`, or it will throw
		an exception since it cannot block in a single-threaded context
	**/
	public function wait(?timeout:Float):Bool
	{
		var c = count;
		if (count <= 0)
		{
			if (timeout == null)
			{
				throw "Lock is currently in locked state: cannot block in a single-threaded context!";
			} else {
				return false;
			}
		} else {
			count++;
			return true;
		}
	}
}
#end

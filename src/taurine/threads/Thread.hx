package taurine.threads;

typedef ThreadData =
#if (TAURINE_NO_THREADS || macro)
	SingleThreadedThread;
#elseif TAURINE_CUSTOM_THREAD
	CustomThread;
#elseif (neko && !interp)
	neko.vm.Thread;
#elseif cpp
	cpp.vm.Thread;
#elseif java
	java.vm.Thread;
#elseif cs
	cs.vm.Thread;
#else
	See_readme_md_file_at_taurine_threads_dir;
#end

abstract Thread(ThreadData) from ThreadData to ThreadData
{
	/**
		Returns the current executing thread.
	**/
	@:extern inline public static function current():ThreadData
	{
		return ThreadData.current();
	}

#if !TAURINE_NO_THREADS
	/**
		Creates a new thread that will execute the `fn` function. When the function completes, the thread will terminate.
	**/
	@:extern inline public static function create(fn:Void->Void):Thread
	{
	}
#end

	@:extern inline public static function readMessage(block:Bool):Dynamic
	{
		return ThreadData.readMessage(block);
	}

	@:extern inline public function sendMessage(msg:Dynamic):Void
	{
		this.sendMessage(msg);
	}

	@:extern inline public static function sleep(secs:Float):Void
	{
#if sys
		Sys.sleep(secs);
#elseif TAURINE_NO_THREADS
		return; //FIXME?
#elseif TAURINE_CUSTOM_THREAD
		ThreadData.sleep(secs);
#else
#error "No sleep implementation"
#end
	}

	//TODO: yield, kill, join

}

#if (TAURINE_NO_THREADS || macro)
/**
	A Single-Threaded Thread is here to emulate a Thread API when the underlying platform has no support for Threads.
	In this case, `create` is obviously missing, since its use would imply in having support for Threads
**/
class SingleThreadedThread
{
	private static var _cur:SingleThreadedThread;

	/**
		Returns the current executing thread. In the case of single-threaded contexts, returns the SingleThreadedThread singleton
	**/
	public static function current()
	{
		if (_cur == null)
		{
			return _cur = new SingleThreadedThread();
		}
		return _cur;
	}

	private var queue:Queue<Dynamic>;
	private function new()
	{
		if (_cur != null)
			throw "Only a single instance of thread allowed in a single threaded context!";
		queue = new Queue();
	}

	/**
		Reads a message sent through `sendMessage`. Messages are queued in a FIFO
	**/
	public static function readMessage(block:Bool):Dynamic
	{
		var cur = current();
		if (cur.queue.empty() && block)
		{
			throw "Queue is empty: cannot block in a single-threaded context!";
		}
		return cur.queue.take();
	}

	/**
		Queues a message which can be read through `readMessage`
	**/
	public function sendMessage(msg:Dynamic):Void
	{
		queue.add(msg);
	}
}
#end

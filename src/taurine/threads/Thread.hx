package taurine.threads;

typedef Thread =
#if TAURINE_NO_THREADS
	SingleThreadedThread;
#elseif TAURINE_CUSTOM_THREAD
	CustomThread;
#elseif neko
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

#if TAURINE_NO_THREADS
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

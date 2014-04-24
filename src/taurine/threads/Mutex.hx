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

**/
abstract Mutex(MutexData) from MutexData to MutexData
{

}

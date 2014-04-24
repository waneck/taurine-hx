package taurine.threads;

typedef GateData =
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
	A gate is the most simple (and safest) Mutex implementation possible.
	It represents an abstract object which ensures that no two threads have acquired the same `Gate` object at the same time.

	Differently from the `Mutex` object, a `Gate` object can only be used via a macro which will guarantee that the underlying block will
	be accessed in a synchronized manner.
	On some platforms,
**/
abstract Gate(GateData)
{
}

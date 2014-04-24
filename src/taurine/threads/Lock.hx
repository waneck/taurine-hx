package taurine.threads;

typedef Lock =
#if neko
	neko.vm.Lock;
#elseif cpp
	cpp.vm.Lock;
#elseif java
	java.vm.Lock;
#elseif cs
	cs.vm.Lock;
#elseif TAURINE_NO_THREADS
	SingleThreadedLock;
#elseif TAURINE_CUSTOM_THREAD
	CustomLock;
#else
	See_readme_md_file_at_taurine_threads_dir;
#end

#if TAURINE_NO_THREADS

#end

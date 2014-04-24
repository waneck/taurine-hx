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
	_GateData;
#elseif cs
	_GateData;
#else
	See_readme_md_file_at_taurine_threads_dir;
#end

/**
	A gate is the safest and most simple Mutex implementation possible.
	It represents an abstract object which ensures that no two threads have acquired the same `Gate` object at the same time.

	Differently from the `Mutex` object, a `Gate` object can *only* be used via a macro which will guarantee that the underlying block will
	be accessed in a synchronized manner. This generates extra guarantees, like that the gate will never leave a mutex locked when exiting
	a critical section
**/
abstract Gate(GateData)
{
	@:extern inline public function new()
	{
		this = new GateData();
	}

	@:noCompletion @:extern inline public function getData():GateData
	{
		return this;
	}

	/**
		Allows a block to be passed to this `Gate` object, which will be executed in a synchronized manner.
		This function executes in a `finally`-like context and is the safest way to avoid deadlocks.

		Example:
		```
			var obj = { gate: new Gate(), number: 0 };
			function safeIncrement()
			{
				obj.gate.synchronized({
					obj.number++;
				});
			}
		```
	**/
	macro public function synchronized(ethis:haxe.macro.Expr, doExpr:haxe.macro.Expr):haxe.macro.Expr
	{
		if (haxe.macro.Context.defined("TAURINE_NO_THREADS"))
		{
			return doExpr;
		} else if (haxe.macro.Context.defined("java")) {
			return macro cs.Lib.lock($ethis, $doExpr);
		} else if (haxe.macro.Context.defined("cs")) {
			return macro java.Lib.lock($ethis, $doExpr);
		} else {
			ethis = $ethis.getData();
			return taurine.threads._internal.LockHelper.transformLock(ethis,doExpr,true);
		}
	}
}

#if (java || cs)
@:dce class _GateData {}
#end

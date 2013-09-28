package taurine.math;

typedef SingleVectorData =
#if (cpp || (flash9 && !TAURINE_MATH_OPT_MEMORY))
	taurine.mem.RawMem
#elseif (js && !TAURINE_JS_BACKWARDS)
	js.html.Float32Array
#else
	haxe.ds.Vector<taurine.Single>
#end;

/**
	This is a supporting implementation for some Math basic types.
	It defines the best platform-specific benefit between size (use 32-bit Floats where possible) and speed.
**/
@:arrayAccess
abstract SingleVector(SingleVectorData) to SingleVectorData
{
	inline public function new(data:SingleVectorData)
	{
		this = data;
	}

	public var length(get,never):Int;

	private inline function get_length():Int
	{
#if (cpp || (flash9 && !TAURINE_MATH_OPT_MEMORY))
		return this.byteLength >>> 2;
#else
		return this.length;
#end
	}

	inline public static function alloc(len:Int):SingleVector
	{
#if (cpp || (flash9 && !TAURINE_MATH_OPT_MEMORY))
		return new SingleVector(taurine.mem.RawMem.alloc(len << 2));
#elseif (js && !TAURINE_JS_BACKWARDS)
		return new SingleVector(new js.html.Float32Array(len));
#else
		return new SingleVector(taurine.ds.VectorTools.create(len));
#end
	}

	@:arrayAccess inline public function get(idx:Int):taurine.Single
	{
#if (cpp || (flash9 && !TAURINE_MATH_OPT_MEMORY))
		return this.getFloat32(idx << 2);
#else
		return this[idx];
#end
	}

	@:arrayAccess inline public function set(idx:Int, val:taurine.Single):taurine.Single
	{
#if (cpp || (flash9 && !TAURINE_MATH_OPT_MEMORY))
		this.setFloat32(idx << 2, val); return val;
#else
		return this[idx] = val;
#end
	}

	inline public function getData():SingleVectorData
	{
		return this;
	}

	#if !(js && TAURINE_JS_BACKWARDS) inline #end public static function blit(src:SingleVector, srcPos:Int, dest:SingleVector, destPos:Int, len:Int):Void
	{
#if (js && !TAURINE_JS_BACKWARDS)
    //TODO: profile if faster than for() + set
		dest.getData().set(src.getData().subarray(srcPos, srcPos+len), destPos);
#elseif (cpp || (flash9 && !TAURINE_MATH_OPT_MEMORY))
		taurine.mem.RawMem.blit(src.getData(), srcPos << 2, dest.getData(), destPos << 2, len << 2);
#elseif js
		//check both are typed arrays
		if (untyped src.buffer != null && dest.buffer != null && src.subarray != null)
		{
			untyped dest.getData().set(src.getData().subarray(srcPos, srcPos+len), destPos);
		} else {
			haxe.ds.Vector.blit(src.getData(),srcPos,dest.getData(), destPos, len);
		}
#else
		haxe.ds.Vector.blit(src.getData(),srcPos,dest.getData(), destPos, len);
#end
	}
}

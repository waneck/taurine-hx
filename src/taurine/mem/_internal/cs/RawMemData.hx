package taurine.mem._internal.cs;
import cs.NativeArray;
import cs.StdTypes;
#if unsafe
import cs.Lib;
import cs.Pointer;
#end

@:nativeGen @:final class RawMemData
{
	public var data(default,null):NativeArray<UInt8>;
#if !unsafe
	private var f:NativeArray<Single>;
	private var d:NativeArray<Float>;
	private var l:NativeArray<haxe.Int64>;
#end

	function new(len:Int)
	{
		this.data = new NativeArray(len);
#if !unsafe
		this.f = new NativeArray(1);
		this.d = new NativeArray(1);
		this.l = new NativeArray(1);
#end
	}

	@:final public inline function getUInt8(offset:Int):Int
	{
		return cast data[offset];
	}

	@:final public inline function setUInt8(offset:Int, v:Int)
	{
		data[offset] = cast v;
	}

#if unsafe @:unsafe #end
	@:final public function getFloat32(offset:Int):Float
	{
#if unsafe
		var ret = .0;
		cs.Lib.fixed({
			var obj = cs.Lib.pointerOfArray(data);
			{
				var obj2:Pointer<Single> = cast obj.add(offset);
				ret = obj2[0];
			}
		});
		return ret;
#else
		var f = f;
		Buffer.BlockCopy(data,offset,f, 0, 4);
		return cast f[0];
#end
	}

#if unsafe @:unsafe #end
	@:final public function setFloat32(offset:Int, val:Float):Void
	{
#if unsafe
		cs.Lib.fixed({
			var obj = cs.Lib.pointerOfArray(data);
			{
				var obj2:Pointer<Single> = cast obj.add(offset);
				obj2[0] = val;
			}
		});
#else
		var f = f;
		f[0] = cast val;
		Buffer.BlockCopy(f, 0, data, offset, 4);
#end
	}

#if unsafe @:unsafe #end
	@:final public function getFloat64(offset:Int):Float
	{
#if unsafe
		var ret = .0;
		cs.Lib.fixed({
			var obj = cs.Lib.pointerOfArray(data);
			{
				var obj2:Pointer<Float> = cast obj.add(offset);
				ret = obj2[0];
			}
		});
		return ret;
#else
		var d = d;
		Buffer.BlockCopy(data,offset,d,0,8);
		return cast d[0];
#end
	}

#if unsafe @:unsafe #end
	@:final public function setFloat64(offset:Int, val:Float):Void
	{
#if unsafe
		cs.Lib.fixed({
			var obj = cs.Lib.pointerOfArray(data);
			{
				var obj2:Pointer<Float> = cast obj.add(offset);
				obj2[0] = val;
			}
		});
#else
		var d = d;
		d[0] = cast val;
		Buffer.BlockCopy(d, 0, data, offset, 8);
#end
	}

#if unsafe @:unsafe #end
	@:final public function getInt64(offset:Int):haxe.Int64
	{
#if unsafe
		var ret:haxe.Int64 = null;
		cs.Lib.fixed({
			var obj = cs.Lib.pointerOfArray(data);
			{
				var obj2:Pointer<haxe.Int64> = cast obj.add(offset);
				ret = obj2[0];
			}
		});
		return ret;
#else
		var l = l;
		Buffer.BlockCopy(data,offset,l,0,8);
		return l[0];
#end
	}

#if unsafe @:unsafe #end
	@:final public function setInt64(offset:Int, val:haxe.Int64):Void
	{
#if unsafe
		cs.Lib.fixed({
			var obj = cs.Lib.pointerOfArray(data);
			{
				var obj2:Pointer<haxe.Int64> = cast obj.add(offset);
				obj2[0] = val;
			}
		});
#else
		var l = l;
		l[0] = val;
		Buffer.BlockCopy(l, 0, data, offset, 8);
#end
	}
}

@:native("System.Buffer")
private extern class Buffer
{
	public static function BlockCopy(src:cs.system.Array, srcOffset:Int, dst:cs.system.Array, dstOffset:Int, count:Int):Void;
}

package taurine.ds;
import haxe.ds.Vector;

class VectorTools
{
	@:generic public static #if !js inline #end function create<T>(length:Int):haxe.ds.Vector<T>
	{
#if !js
		return new haxe.ds.Vector(length);
#else
		return untyped __new__(Array, length);
#end
	}

#if js
	//typed arrays check
	static var _Float32Array:Dynamic;
	static var _Float64Array:Dynamic;
	static var _Int32Array:Dynamic;
	static var _UInt16Array:Dynamic;
	static var _UInt8Array:Dynamic;

	static function __init__()
	{
		if (untyped __js__("typeof Float32Array != undefined"))
		{
			_Float32Array = js.html.Float32Array;
			_Float64Array = js.html.Float64Array;
			_Int32Array = js.html.Int32Array;
			_UInt16Array = js.html.Uint16Array;
			_UInt8Array = js.html.Uint8Array;
		} else {
			_Float32Array = _Float64Array = _Int32Array = _UInt16Array = _UInt8Array = Array;
		}
	}

	public static inline function create_Int(length:Int):Vector<Int>
	{
		return untyped __new__(_Int32Array, length);
	}

	public static inline function create_Float(length:Int):Vector<Float>
	{
		return untyped __new__(_Float64Array, length);
	}

	public static inline function create_taurine_Single(length:Int):Vector<taurine.Single>
	{
		return untyped __new__(_Float32Array, length);
	}

	public static inline function create_taurine_UInt16(length:Int):Vector<taurine.UInt16>
	{
		return untyped __new__(_UInt16Array, length);
	}

	public static inline function create_taurine_UInt8(length:Int):Vector<taurine.UInt8>
	{
		return untyped __new__(_UInt8Array, length);
	}
#end
}

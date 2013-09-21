package taurine.mem;

typedef RawMemData =

#if js
	js.html.DataView //if you need backwards-compatibility, use -D TAURINE_JS_BACKWARDS
#elseif (neko || cpp || php)
	haxe.io.BytesData
#elseif java
	java.nio.ByteBuffer
#elseif cs
	taurine.mem._internal.cs.RawMemData
#elseif flash9
	flash.util.ByteArray
#else
	haxe.io.BytesData //we'll just use Haxe Input/Output implementation
#end;

/**
	Abstraction to the fastest implementation to store different types of primitives sequentially.
	The implementation is guaranteed to be faster or at least as fast as using haxe.io.* package.
	Byte order is **unspecified**, but is by preference the same as the native byte order.

	If backwards-compatibility is needed for JavaScript, define -D TAURINE_JS_BACKWARDS
**/
abstract RawMem(RawMemData)
{
	/**
		The total length - in bytes - of the raw memory
	**/
	public var byteLength(get,never):Int;

	private inline function get_byteLength():Int
	{
#if js
		return this.byteLength;
#elseif neko
		return untyped $ssize(this);
#elseif php
		return untyped __call__("strlen", this);
#elseif cs
		return this.data.Length;
#elseif java
		return this.capacity();
#else
		return this.length;
#end
	}

	/**
		Allocates a new RawMem object with the target `byteLength` size.
		This should be considered an expensive operation.
	**/
	public static inline function alloc(byteLength:Int):RawMem
	{
#if (js && TAURINE_JS_BACKWARDS)
		return untyped taurine.mem._internal.js.RawMemCompat.alloc(byteLength);
#elseif js
		return untyped new js.html.DataView(new js.html.ArrayBuffer(byteLength));
#elseif (neko || cpp || php || flash9)
		return untyped haxe.io.Bytes.alloc(byteLength).getData();
#elseif java
		return untyped java.nio.ByteBuffer.allocateDirect(byteLength).order(java.nio.ByteOrder.nativeOrder());
#elseif cs
		return untyped new taurine.mem._internal.cs.RawMemData(byteLength);
#else
		return untyped haxe.io.Bytes.alloc(byteLength).getData();
#end
	}

	/**
		Gets a single byte at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public inline function getUInt8(offset:Int):Int
	{
#if js
		return this.getUint8(offset);
#elseif neko
		return untyped $sget(this, offset);
#elseif cpp
		return untyped __global__.__hxcpp_memory_get_byte(this, offset) & 0xFF;
#elseif php
		return untyped __call__("ord", this[offset]);
#elseif flash9
		return this[offset];
#elseif java
		return (cast this.get(offset)) & 0xFF;
#elseif cs
		return this.getUInt8(offset);
#else
		return untyped this[offset] & 0xFF;
#end
	}

	/**
		Sets a single byte at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public inline function setUInt8(offset:Int, val:Int):Void
	{
#if js
		this.setUint8(offset, val);
#elseif neko
		untyped $sset(this, offset, val);
#elseif cpp
		untyped __global__.__hxcpp_memory_set_byte(this, offset, val & 0xFF);
#elseif php
		this[offset] = untyped __call__("chr", val);
#elseif flash9
		this[offset] = val;
#elseif java
		this.put(offset, val);
#elseif cs
		this.setUInt8(offset, val);
#else
		this[offset] = val & 0xFF;
#end
	}

	/**
		Gets a short int (16 bits) at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public inline function getUInt16(offset:Int):Int
	{
#if js
		return this.getUint16(offset);
#elseif cpp
		return untyped __global__.__hxcpp_memory_get_ui16(this, offset);
#elseif java
		return (cast this.getShort(offset)) & 0xFFFF;
#else
		return getUInt8(offset) | (getUInt8(offset + 1) << 8);
#end
	}

	/**
		Sets a short int (16 bits) at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public inline function setUInt16(offset:Int, val:Int):Void
	{
#if js
		this.setUint16(offset, val);
#elseif cpp
		untyped __global__.__hxcpp_memory_set_i16(this, offset, val);
#elseif java
		this.putShort(offset, cast val);
#else
		setUInt8(offset, val); setUInt8(offset+1, val >> 8);
#end
	}

	/**
		Gets an int (32 bits) at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public inline function getInt32(offset:Int):Int
	{
#if js
		return this.getInt32(offset);
#elseif cpp
		return untyped __global__.__hxcpp_memory_get_i32(this, offset);
#elseif java
		return this.getInt(offset);
#elseif flash9
		this.position = offset;
		return this.readInt(offset);
#else
		return getUInt8(offset) | (getUInt8(offset+1) << 8) | (getUInt8(offset+2) << 16) | (getUInt8(offset+3) << 24);
#end
	}

	/**
		Sets an int (32 bits) at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public inline function setInt32(offset:Int, val:Int):Void
	{
#if js
		this.setInt32(offset, val);
#elseif cpp
		untyped __global__.__hxcpp_memory_set_i32(this, offset, val);
#elseif java
		this.putInt(offset, val);
#elseif flash9
		this.position = offset;
		this.writeInt(val);
#else
		setUInt8(offset, val); setUInt8(offset+1, val >> 8); setUInt8(offset+2, val >> 16); setUInt8(offset+3, val >>> 24);
#end
	}

	/**
		Gets a 32-bit float at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public #if (js || cpp || java || cs || flash9) inline #end function getFloat32(offset:Int):taurine.Single
	{
#if js
		return this.getFloat32(offset);
#elseif cpp
		return untyped __global__.__hxcpp_memory_get_float(this, offset);
#elseif java
		return this.getFloat(offset);
#elseif cs
		return this.getFloat32(offset);
#elseif flash9
		this.position = offset;
		return this.readFloat();
#else //TODO: OPTIMIZATION - evaluate if calling bytes_to_float will be faster on neko
		var b0 = getUInt8(offset), b1 = getUInt8(offset+1), b2 = getUInt8(offset+2), b3 = getUInt8(offset+3);
		var sign = 1 - ((b0 >> 7) << 1);
		var exp = (((b0 << 1) & 0xFF) | (b1 >> 7)) - 127;
		var sig = ((b1 & 0x7F) << 16) | (b2 << 8) | b3;
		if (sig == 0 && exp == -127)
			return 0.0;
		return sign*(1 + Math.pow(2, -23)*sig) * Math.pow(2, exp);
#end
	}

	/**
		Sets a 32-bit float at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public #if (js || cpp || java || cs || flash9) inline #end function setFloat32(offset:Int, val:taurine.Single):Void
	{
#if js
		this.setFloat32(offset, val);
#elseif cpp
		untyped __global__.__hxcpp_memory_set_float(this, offset, val);
#elseif java
		this.putFloat(offset, val);
#elseif cs
		this.setFloat32(offset, val);
#elseif flash9
		this.position = offset;
		this.writeFloat(val);
#else //TODO: OPTIMIZATION - evaluate if alloc a temp array and calling float_to_bytes will be faster on neko
		if (val == 0.0)
		{
			setInt32(offset, 0);
			return;
		}
		var exp = Math.floor(Math.log(Math.abs(val)) / LN2);
		var sig = (Math.floor(Math.abs(val) / Math.pow(2, exp) * (2 << 22)) & 0x7FFFFF);
		var b1 = (exp + 0x7F) >> 1 | (exp>0 ? ((val<0) ? 1<<7 : 1<<6) : ((val<0) ? 1<<7 : 0)),
			b2 = (exp + 0x7F) << 7 & 0xFF | (sig >> 16 & 0x7F),
			b3 = (sig >> 8) & 0xFF,
			b4 = sig & 0xFF;
		setUInt8(offset, b1); setUInt8(offset+1,b2); setUInt8(offset+2,b3); setUInt8(offset+3,b4);
#end
	}

	/**
		Gets a 64-bit float at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public #if (js || cpp || java || cs || flash9) inline #end function getFloat64(offset:Int):Float
	{
#if js
		return this.getFloat64(offset);
#elseif cpp
		return untyped __global__.__hxcpp_memory_get_double(this, offset);
#elseif java
		return this.getDouble(offset);
#elseif cs
		return this.getFloat64(offset);
#elseif flash9
		this.position = offset;
		return this.readDouble();
#else
		var b0 = getUInt8(offset), b1 = getUInt8(offset+1), b2 = getUInt8(offset+2), b3 = getUInt8(offset+3);
		var b4 = getUInt8(offset+4), b5 = getUInt8(offset+5), b6 = getUInt8(offset+6), b7 = getUInt8(offset+7);

		var sign = 1 - ((b0 >> 7) << 1); // sign = bit 0
		var exp = (((b0 << 4) & 0x7FF) | (b1 >> 4)) - 1023; // exponent = bits 1..11
		var sig = (((b1&0xF) << 16) | (b2 << 8) | b3 ) * 4294967296. +
				(b4 >> 7) * 2147483648 +
				(((b4&0x7F) << 24) | (b5 << 16) | (b6 << 8) | b7);
		if (sig == 0 && exp == -1023)
			return 0.0;
		return sign * (1.0 + Math.pow(2, -52) * sig) * Math.pow(2, exp);
#end
	}

	/**
		Sets a 32-bit float at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public #if (js || cpp || java || cs || flash9) inline #end function setFloat64(offset:Int, val:Float):Void
	{
#if js
		this.setFloat64(offset, val);
#elseif cpp
		untyped __global__.__hxcpp_memory_set_double(this, offset, val);
#elseif java
		this.putDouble(offset, val);
#elseif cs
		this.setFloat64(offset, val);
#elseif flash9
		this.position = offset;
		this.writeDouble(val);
#else
		if (val == 0)
		{
			setInt32(offset,0); setInt32(offset+4,0);
			return;
		}
		var exp = Math.floor(Math.log(Math.abs(val)) / LN2);
		var sig : Int = Math.floor(Math.abs(val) / Math.pow(2, exp) * Math.pow(2, 52));
		var sig_h = (sig & cast 34359738367);
		var sig_l = Math.floor((sig / Math.pow(2,32)));
		var b1 = (exp + 0x3FF) >> 4 | (exp>0 ? ((val<0) ? 1<<7 : 1<<6) : ((val<0) ? 1<<7 : 0)),
			b2 = (exp + 0x3FF) << 4 & 0xFF | (sig_l >> 16 & 0xF),
			b3 = (sig_l >> 8) & 0xFF,
			b4 = sig_l & 0xFF,
			b5 = (sig_h >> 24) & 0xFF,
			b6 = (sig_h >> 16) & 0xFF,
			b7 = (sig_h >> 8) & 0xFF,
			b8 = sig_h & 0xFF;
		setUInt8(offset, b1); setUInt8(offset+1,b2); setUInt8(offset+2,b3); setUInt8(offset+3,b4);
		setUInt8(offset+4, b5); setUInt8(offset+5,b6); setUInt8(offset+6,b7); setUInt8(offset+7,b8);
#end
	}

	/**
		Gets a long (64 bits) at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public inline function getInt64(offset:Int):haxe.Int64
	{
#if cs
		return this.getInt64(offset);
#elseif java
		return this.getLong(offset);
#else
		return haxe.Int64.make(getInt32(offset), getInt32(offset+4));
#end
	}

	/**
		Sets a long (64 bits) at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	@:access(haxe.Int64)
	public inline function setInt64(offset:Int, val:haxe.Int64):Void
	{
#if cs
		this.setInt64(offset, val);
#elseif java
		this.putLong(offset, val);
#else
		setInt32(offset, val.high); setInt32(offset+4, val.low);
#end
	}

	static inline var LN2 = taurine.math.MacroMath.reduce(Math.log(2));
}

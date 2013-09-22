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

## Availability
	There is a PHP implementation. However, it is not working correctly (see unit tests).
	It works as expected on all other Haxe targets
**/
abstract RawMem(RawMemData)
{

#if false // (js && TAURINE_JS_BACKWARDS)
	private static var LITTLE_ENDIAN = {
		if (untyped __js__('typeof DataView == "undefined"'))
		{
			true;
		} else {
			var buffer = new js.html.ArrayBuffer(2);
			new js.html.DataView(buffer).setInt16(0,256,true);
			new js.html.Int16Array(buffer)[0] == 256;
		}
	};
#elseif js
	private static inline var LITTLE_ENDIAN = true;
#end
	/**
		The total length - in bytes - of the raw memory
	**/
	public var byteLength(get,never):Int;

	/**
		Copies `length` of bytes from `src`, beginning at `srcPos` to
		`dest`, beginning at `destPos`

		WARNING: On some targets, it may not do bounds check
	**/
	#if ( (js && !TAURINE_JS_BACKWARDS) || neko || cs || flash9 ) inline #end
	public static function blit(src:RawMem, srcPos:Int, dest:RawMem, destPos:Int, len:Int):Void
	{
#if (js && TAURINE_JS_BACKWARDS)
		//check both are typed arrays
		if (dest.getData().buffer != null && src.getData().buffer != null && untyped __js__('typeof Uint8Array !== "undefined"') )
		{
			var dstu8 = new js.html.Uint8Array(dest.getData().buffer, destPos, len);
			var srcu8 = new js.html.Uint8Array(src.getData().buffer, srcPos, len);
			dstu8.set(srcu8);
		} else {
			var b1 = dest.getData();
			var b2 = src.getData();
			if( b1 == b2 && destPos > srcPos ) {
				var i = len;
				while( i > 0 ) {
					i--;
					b1.setUint8(i + destPos, b2.getUint8(i + srcPos));
				}
				return;
			}
			for( i in 0...len )
			{
				b1.setUint8(i + destPos, b2.getUint8(i + srcPos));
			}
		}
#elseif js
		var dstu8 = new js.html.Uint8Array(dest.getData().buffer, destPos, len);
		var srcu8 = new js.html.Uint8Array(src.getData().buffer, srcPos, len);
		dstu8.set(srcu8);
#elseif neko
		untyped $sblit(dest, destPos, src, srcPos, len);
#elseif php
		untyped __php__("substr($dest, 0, $destPos) . substr($src, $srcPos, $len) . substr($dest, $destPos+$len)");
#elseif flash9
		dest.getData().position = destPos;
		dest.getData().writeBytes(src,srcPos,len);
#elseif java
		if (src.getData().hasArray())
		{
			dest.getData().position(destPos);
			dest.getData().put(src.getData().array(), src.getData().arrayOffset() + srcPos, len);
		} else {
			src.getData().position(srcPos);
			var src = src.getData().slice();
			src.limit(len);
			dest.getData().position(destPos);
			dest.getData().put(src);
		}
#elseif cs
		cs.system.Array.Copy(src.getData().data, srcPos, dest.getData().data, destPos, len);
#elseif (cpp && !TAURINE_NO_INLINE_CPP)
		untyped __cpp__('memmove(  dest->GetBase() + destPos, src->GetBase() + srcPos, len)');
#else
		var b1 = dest.getData();
		var b2 = src.getData();
		if( b1 == b2 && destPos > srcPos ) {
			var i = len;
			while( i > 0 ) {
				i--;
				b1[i + destPos] = b2[i + srcPos];
			}
			return;
		}
		for( i in 0...len )
			b1[i+destPos] = b2[i+srcPos];
#end
	}

	inline public function getData():RawMemData
	{
		return this;
	}

	public function isLittleEndian():Bool
	{
#if flash9
		return this.endian == untyped "littleEndian";
#elseif java
		return this.order() == java.nio.ByteOrder.LITTLE_ENDIAN;
#elseif js
		return LITTLE_ENDIAN;
#elseif (cs || cpp)
		if (byteLength > 2)
		{
			var v1 = getUInt8(0), v2 = getUInt8(1);
			setUInt16(0,0xFF);
			var ret = getUInt8(0) == 0xFF;
			setUInt8(0,v1); setUInt8(1,v2);
			return ret;
		} else {
			var tmp = alloc(2);
			tmp.setUInt16(0,0xFF);
			return tmp.getUInt8(0) == 0xFF;
		}
#else
		return true;
#end
	}

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
		untyped $sset(this, offset, val & 0xFF);
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
		return this.getUint16(offset, LITTLE_ENDIAN);
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
		this.setUint16(offset, val, LITTLE_ENDIAN);
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
		return this.getInt32(offset, LITTLE_ENDIAN);
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
		this.setInt32(offset, val, LITTLE_ENDIAN);
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
		return this.getFloat32(offset, LITTLE_ENDIAN);
#elseif cpp
		return untyped __global__.__hxcpp_memory_get_float(this, offset);
#elseif java
		return this.getFloat(offset);
#elseif cs
		return this.getFloat32(offset);
#elseif flash9
		this.position = offset;
		return this.readFloat();
#elseif neko
		if (offset == 0) return _float_of_bytes(this,false);
		var b = untyped $ssub(this,offset,4);
		return _float_of_bytes(b, false);
#elseif php
		if (offset == 0) return untyped __call__("unpack", "f", this)[1];
		var b = untyped __call__("substr", this, offset, 4);
		return untyped __call__('unpack', 'f', b)[1];
#else
		var b3 = getUInt8(offset), b2 = getUInt8(offset+1), b1 = getUInt8(offset+2), b0 = getUInt8(offset+3);
		var sign = 1 - ((b0 >> 7) << 1);
		var exp = (((b0 << 1) & 0xFF) | (b1 >> 7)) - 127;
		var sig = ((b1 & 0x7F) << 16) | (b2 << 8) | b3;
		if (exp == 128)
			if (sig == 0)
				return sign / 0.0;
			else
				return taurine.math.FastMath.NaN;
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
		this.setFloat32(offset, val, LITTLE_ENDIAN);
#elseif cpp
		untyped __global__.__hxcpp_memory_set_float(this, offset, val);
#elseif java
		this.putFloat(offset, val);
#elseif cs
		this.setFloat32(offset, val);
#elseif flash9
		this.position = offset;
		this.writeFloat(val);
#elseif neko
		var b = _float_bytes(val, false);
		for (i in 0...4)
			setUInt8(offset + i, untyped $sget(b,i));
#elseif php
		var b = untyped __call__('pack', 'f', val);
		for (i in 0...4)
			setUInt8(offset + i, b[i]);
#else
		if (val == 0.0)
		{
			for(i in 0...4)
				setUInt8(offset+i,0);
		} else if (val != val) {
			setUInt8(offset+3, 0x7F); setUInt8(offset+2,0xC0);
		} else if (val * 2 == val && !Math.isFinite(val)) {
			if (val > 0)
			{
				setUInt8(offset+3, 0x7F);
			} else {
				setUInt8(offset+3, 0xFF);
			}
			setUInt8(offset+2, 0x80);
			for (i in 0...2)
				setUInt8(offset+i,0);
		} else {
			var exp = Math.floor(Math.log(Math.abs(val)) / LN2);
			var sig = (Math.floor(Math.abs(val) / Math.pow(2, exp) * (2 << 22)) & 0x7FFFFF);
			var b1 = (exp + 0x7F) >> 1 | (exp>0 ? ((val<0) ? 1<<7 : 1<<6) : ((val<0) ? 1<<7 : 0)),
				b2 = (exp + 0x7F) << 7 & 0xFF | (sig >> 16 & 0x7F),
				b3 = (sig >> 8) & 0xFF,
				b4 = sig & 0xFF;
			setUInt8(offset, b4); setUInt8(offset+1,b3); setUInt8(offset+2,b2); setUInt8(offset+3,b1);
		}
#end
	}

	/**
		Gets a 64-bit float at the specified offset.
		WARNING: bounds may not be checked on all targets
	**/
	public #if (js || cpp || java || cs || flash9) inline #end function getFloat64(offset:Int):Float
	{
#if js
		return this.getFloat64(offset, LITTLE_ENDIAN);
#elseif cpp
		return untyped __global__.__hxcpp_memory_get_double(this, offset);
#elseif java
		return this.getDouble(offset);
#elseif cs
		return this.getFloat64(offset);
#elseif flash9
		this.position = offset;
		return this.readDouble();
#elseif neko
		if (offset == 0) return _double_of_bytes(this,false);
		var b = untyped $ssub(this,offset,8);
		return _double_of_bytes(b, false);
#elseif php
		if (offset == 0) return untyped __call__('unpack', 'd', this)[1];
		var b = untyped __call__('substr', this, offset, 8);
		return untyped __call__('unpack', 'd', b)[1];
#else
		var b7 = getUInt8(offset), b6 = getUInt8(offset+1), b5 = getUInt8(offset+2), b4 = getUInt8(offset+3);
		var b3 = getUInt8(offset+4), b2 = getUInt8(offset+5), b1 = getUInt8(offset+6), b0 = getUInt8(offset+7);

		var sign = 1 - ((b0 >> 7) << 1); // sign = bit 0
		var exp = (((b0 << 4) & 0x7FF) | (b1 >> 4)) - 1023; // exponent = bits 1..11
		var sig = (((b1&0xF) << 16) | (b2 << 8) | b3 ) * 4294967296. +
				(b4 >> 7) * 2147483648 +
				(((b4&0x7F) << 24) | (b5 << 16) | (b6 << 8) | b7);
		if (exp == 1024)
		{
			if (sig == 0)
				return sign / 0.0;
			else
				return taurine.math.FastMath.NaN;
		}

		if (exp == -1023)
		{
			if (sig == 0)
				return .0;
			//TODO: denormalized numbers
		}
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
		this.setFloat64(offset, val, LITTLE_ENDIAN);
#elseif cpp
		untyped __global__.__hxcpp_memory_set_double(this, offset, val);
#elseif java
		this.putDouble(offset, val);
#elseif cs
		this.setFloat64(offset, val);
#elseif flash9
		this.position = offset;
		this.writeDouble(val);
#elseif neko
		var b = _double_bytes(val, false);
		for (i in 0...8)
			setUInt8(offset + i, untyped $sget(b,i));
#elseif php
		var b = untyped __call__('pack', 'd', val);
		for (i in 0...8)
			setUInt8(offset + i, untyped this[i]);
#else
		if (val == 0)
		{
			for(i in 0...8)
				setUInt8(offset+i,0);
		} else if (val != val) {
			setUInt8(offset+7, 0x7F); setUInt8(offset+6, 0xF8);
		} else if (val * 2 == val && !Math.isFinite(val)) {
			if (val > 0)
			{
				setUInt8(offset+7, 0x7F);
			} else {
				setUInt8(offset+7, 0xFF);
			}
			setUInt8(offset+6,0xF0);
			for (i in 0...6)
				setUInt8(offset+i,0);
		} else {
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
			setUInt8(offset, b8); setUInt8(offset+1,b7); setUInt8(offset+2,b6); setUInt8(offset+3,b5);
			setUInt8(offset+4, b4); setUInt8(offset+5,b3); setUInt8(offset+6,b2); setUInt8(offset+7,b1);
		}
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

#if neko
	static var _float_of_bytes = neko.Lib.load("std","float_of_bytes",2);
	static var _double_of_bytes = neko.Lib.load("std","double_of_bytes",2);
	static var _float_bytes = neko.Lib.load("std","float_bytes",2);
	static var _double_bytes = neko.Lib.load("std","double_bytes",2);
#end
}

package taurine;

/**
	Cross-platform implementation of an unsigned byte (8 bits).
**/
abstract UInt8(UInt8_t)
{
	public inline function new(i:Int)
	{
#if !(java || cs || cpp)
		this = untyped (i & 0xFF);
#else
		this = cast i;
#end
	}

	public static inline function fromInt(i:Int):UInt8
	{
#if !(java || cs || cpp)
		return cast i & 0xFF;
#else
		return cast i;
#end
	}

	private inline function t():UInt8_t
	{
		return this;
	}

	private inline function i():Int
	{
#if !(java || cs || cpp || php)
		return this;
#else
		return untyped this;
#end
	}

	@:to public inline function toInt():Int
	{
#if java
		return (cast this) & 0xFF; //force unsigned
#elseif (cpp || php || cs)
		return cast this;
#else
		return this;
#end
	}

	@:op(A+B) public static inline function add(a:UInt8, i:Int):UInt8
	{
		return fromInt(a.i() + i);
	}

	@:op(A++) public inline function incr():UInt8
	{
		return cast (this = add(cast this, 1).t());
	}

	@:op(A--) public inline function decr():UInt8
	{
		return cast (this = add(cast this, -1).t());
	}

	@:op(A-B) public static inline function sub(a:UInt8, i:Int):UInt8
	{
		return fromInt(untyped a.t() - i);
	}

	@:op(A+B) public static inline function add_uint8(a:UInt8, i:UInt8):UInt8
	{
		return fromInt(a.i() + i.i());
	}

	@:op(A-B) public static inline function sub_uint8(a:UInt8, i:UInt8):UInt8
	{
		return fromInt(untyped a.t() - i.t());
	}

	@:op(A*B) public static inline function mul(a:UInt8, i:Int):UInt8
	{
		return fromInt(untyped a.t() * i);
	}

	@:op(A*B) public static inline function mul_uint8(a:UInt8, i:UInt8):UInt8
	{
		return fromInt(untyped a.t() * i.t());
	}

	@:op(A/B) public static inline function div(a:UInt8, i:Int):UInt8
	{
#if (java || cs) //force integer division
		return fromInt( Std.int(a.toInt() / i) );
#else
		return fromInt( Std.int(untyped a.t() / i) );
#end
	}

	@:op(A/B) public static inline function div_uint8(a:UInt8, i:UInt8):UInt8
	{
#if (java || cs) //force integer division
		return fromInt( Std.int(a.toInt() / i.toInt()) );
#else
		return fromInt( Std.int(untyped a.t() / i.t()) );
#end
	}

	@:op(A%B) public static inline function mod(a:UInt8, i:Int):UInt8
	{
		return fromInt( Std.int(a.toInt() % i) );
	}

	@:op(A%B) public static inline function mod_uint8(a:UInt8, i:UInt8):UInt8
	{
		return fromInt( Std.int(a.toInt() % i.toInt()) );
	}

	@:op(A<<B) public static inline function shl(a:UInt8, i:Int):UInt8
	{
		return fromInt( (untyped a.t()) << i);
	}

	@:op(A<<B) public static inline function shl_uint8(a:UInt8, i:UInt8):UInt8
	{
		return fromInt( (untyped a) << (untyped i) );
	}

	@:op(A>>B) public static inline function shr(a:UInt8, b:Int):UInt8
	{
		return cast ((untyped a) >>> b);
	}

	@:op(A>>B) public static inline function shr_uintu(a:UInt8, i:UInt8):UInt8
	{
		return cast ((untyped a) >>> (untyped i));
	}

	@:op(A>>>B) public static inline function ushr(a:UInt8, b:Int):UInt8
	{
		return cast ((untyped a) >>> b);
	}

	@:op(A>>>B) public static inline function ushr_uintu(a:UInt8, i:UInt8):UInt8
	{
		return cast ((untyped a) >>> (untyped i));
	}

	@:op(A&B) public static inline function and(a:UInt8, i:Int):UInt8
	{
		return cast ((untyped a) & i);
	}

	@:op(A&B) public static inline function and_uint8(a:UInt8, i:UInt8):UInt8
	{
		return cast ((untyped a) & (untyped i));
	}

	@:op(A|B) public static inline function or(a:UInt8, i:Int):UInt8
	{
		return fromInt((untyped a) | i);
	}

	@:op(A|B) public static inline function or_uint8(a:UInt8, i:UInt8):UInt8
	{
		return cast ((untyped a) | (untyped i));
	}

	@:op(A^B) public static inline function xor(a:UInt8, i:Int):UInt8
	{
		return fromInt((untyped a) ^ i);
	}

	@:op(A^B) public static inline function xor_uint8(a:UInt8, i:UInt8):UInt8
	{
		return fromInt( (untyped a) ^ (untyped i) );
	}

	public static inline function compare(a:UInt8, b:Int):Int
	{
#if java //force unsigned compare
		return ( (cast a) & 0xFF ) - b;
#else
		//already unsigned
		return (cast a) - b;
#end
	}

	@:op(A>B) public static inline function gt(a:UInt8, i:Int):Bool
	{
		return compare(a,i) > 0;
	}

	@:op(A>B) public static inline function gt_uint8(a:UInt8, i:UInt8):Bool
	{
		return compare(a,i.toInt()) > 0;
	}

	@:op(A>=B) public static inline function gte(a:UInt8, i:Int):Bool
	{
		return compare(a,i) >= 0;
	}

	@:op(A>=B) public static inline function gte_uint8(a:UInt8, i:UInt8):Bool
	{
		return compare(a,i.toInt()) >= 0;
	}

	@:op(A<B) public static inline function lt(a:UInt8, i:Int):Bool
	{
		return compare(a,i) < 0;
	}

	@:op(A<B) public static inline function lt_uint8(a:UInt8, i:UInt8):Bool
	{
		return compare(a,i.toInt()) < 0;
	}

	@:op(A<=B) public static inline function lte(a:UInt8, i:Int):Bool
	{
		return compare(a,i) <= 0;
	}

	@:op(A<=B) public static inline function lte_uint8(a:UInt8, i:UInt8):Bool
	{
		return compare(a,i.toInt()) <= 0;
	}

	@:to public inline function toString()
	{
#if java
		return (i() & 0xFF) + "";
#else
		return this + "";
#end
	}

	@:to public inline function toDynamic():Dynamic
	{
		return toInt();
	}

}

typedef UInt8_t = #if cpp haxe.io.BytesData.Unsigned_char__ #elseif php Unsigned_char__ #elseif java java.StdTypes.Int8 #elseif cs cs.StdTypes.UInt8 #else Int #end;

#if php
@:native("haxe.io.Unsigned_char__")
private class Unsigned_char__ {}
#end

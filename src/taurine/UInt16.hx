package taurine;

/**
	Cross-platform implementation of an unsigned short (16 bits).
**/
abstract UInt16(UInt16_t)
{
	public inline function new(i:Int)
	{
#if !(java || cs)
		this = untyped (i & 0xFFFF);
#else
		this = cast i;
#end
	}

	public static inline function fromInt(i:Int):UInt16
	{
#if !(java || cs)
		return cast i & 0xFFFF;
#else
		return cast i;
#end
	}

	private inline function t():UInt16_t
	{
		return this;
	}

	private inline function i():Int
	{
#if !(java || cs)
		return this;
#else
		return untyped this;
#end
	}

	@:to public inline function toInt():Int
	{
#if java
		return (cast this) & 0xFFFF; //force unsigned
#elseif cs
		return cast this;
#else
		return this;
#end
	}

	@:op(A+B) public static inline function add(a:UInt16, i:Int):UInt16
	{
		return fromInt(a.i() + i);
	}

	@:op(A++) public inline function incr():UInt16
	{
		return cast (this = add(cast this, 1).t());
	}

	@:op(A--) public inline function decr():UInt16
	{
		return cast (this = add(cast this, -1).t());
	}

	@:op(A-B) public static inline function sub(a:UInt16, i:Int):UInt16
	{
		return fromInt(untyped a.t() - i);
	}

	@:op(A+B) public static inline function add_uint8(a:UInt16, i:UInt16):UInt8
	{
		return fromInt(a.i() + i.i());
	}

	@:op(A-B) public static inline function sub_uint8(a:UInt16, i:UInt16):UInt8
	{
		return fromInt(untyped a.t() - i.t());
	}

	@:op(A*B) public static inline function mul(a:UInt16, i:Int):UInt16
	{
		return fromInt(untyped a.t() * i);
	}

	@:op(A*B) public static inline function mul_uint8(a:UInt16, i:UInt16):UInt8
	{
		return fromInt(untyped a.t() * i.t());
	}

	@:op(A/B) public static inline function div(a:UInt16, i:Int):UInt16
	{
#if (java || cs) //force integer division
		return fromInt( Std.int(a.toInt() / i) );
#else
		return fromInt( Std.int(untyped a.t() / i) );
#end
	}

	@:op(A/B) public static inline function div_uint8(a:UInt16, i:UInt16):UInt8
	{
#if (java || cs) //force integer division
		return fromInt( Std.int(a.toInt() / i.toInt()) );
#else
		return fromInt( Std.int(untyped a.t() / i.t()) );
#end
	}

	@:op(A%B) public static inline function mod(a:UInt16, i:Int):UInt16
	{
		return fromInt( Std.int(a.toInt() % i) );
	}

	@:op(A%B) public static inline function mod_uint8(a:UInt16, i:UInt16):UInt8
	{
		return fromInt( Std.int(a.toInt() % i.toInt()) );
	}

	@:op(A<<B) public static inline function shl(a:UInt16, i:Int):UInt16
	{
		return fromInt( (untyped a.t()) << i);
	}

	@:op(A<<B) public static inline function shl_uint8(a:UInt16, i:UInt16):UInt8
	{
		return fromInt( (untyped a) << (untyped i) );
	}

	@:op(A>>B) public static inline function shr(a:UInt16, b:Int):UInt16
	{
		return cast ((untyped a) >>> b);
	}

	@:op(A>>B) public static inline function shr_uintu(a:UInt16, i:UInt16):UInt8
	{
		return cast ((untyped a) >>> (untyped i));
	}

	@:op(A>>>B) public static inline function ushr(a:UInt16, b:Int):UInt16
	{
		return cast ((untyped a) >>> b);
	}

	@:op(A>>>B) public static inline function ushr_uintu(a:UInt16, i:UInt16):UInt8
	{
		return cast ((untyped a) >>> (untyped i));
	}

	@:op(A&B) public static inline function and(a:UInt16, i:Int):UInt16
	{
		return cast ((untyped a) & i);
	}

	@:op(A&B) public static inline function and_uint8(a:UInt16, i:UInt16):UInt8
	{
		return cast ((untyped a) & (untyped i));
	}

	@:op(A|B) public static inline function or(a:UInt16, i:Int):UInt16
	{
		return fromInt((untyped a) | i);
	}

	@:op(A|B) public static inline function or_uint8(a:UInt16, i:UInt16):UInt8
	{
		return cast ((untyped a) | (untyped i));
	}

	@:op(A^B) public static inline function xor(a:UInt16, i:Int):UInt16
	{
		return fromInt((untyped a) ^ i);
	}

	@:op(A^B) public static inline function xor_uint8(a:UInt16, i:UInt16):UInt8
	{
		return fromInt( (untyped a) ^ (untyped i) );
	}

	public static inline function compare(a:UInt16, b:Int):Int
	{
#if java //force unsigned compare
		return ( (cast a) & 0xFFFF ) - b;
#else
		//already unsigned
		return (cast a) - b;
#end
	}

	@:op(A>B) public static inline function gt(a:UInt16, i:Int):Bool
	{
		return compare(a,i) > 0;
	}

	@:op(A>B) public static inline function gt_uint8(a:UInt16, i:UInt16):Bool
	{
		return compare(a,i.toInt()) > 0;
	}

	@:op(A>=B) public static inline function gte(a:UInt16, i:Int):Bool
	{
		return compare(a,i) >= 0;
	}

	@:op(A>=B) public static inline function gte_uint8(a:UInt16, i:UInt16):Bool
	{
		return compare(a,i.toInt()) >= 0;
	}

	@:op(A<B) public static inline function lt(a:UInt16, i:Int):Bool
	{
		return compare(a,i) < 0;
	}

	@:op(A<B) public static inline function lt_uint8(a:UInt16, i:UInt16):Bool
	{
		return compare(a,i.toInt()) < 0;
	}

	@:op(A<=B) public static inline function lte(a:UInt16, i:Int):Bool
	{
		return compare(a,i) <= 0;
	}

	@:op(A<=B) public static inline function lte_uint8(a:UInt16, i:UInt16):Bool
	{
		return compare(a,i.toInt()) <= 0;
	}

	@:to public inline function toString()
	{
#if java
		return (i() & 0xFFFF) + "";
#else
		return this + "";
#end
	}

	@:to public inline function toDynamic():Dynamic
	{
		return toInt();
	}

}

typedef UInt16_t = #if java java.StdTypes.Int16 #elseif cs cs.StdTypes.UInt16 #else Int #end;

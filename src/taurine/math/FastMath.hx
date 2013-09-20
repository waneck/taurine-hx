package taurine.math;

/**
	Implements faster, but lower precision Math intrinsics.
**/
class FastMath
{
	public static inline var NaN = #if cpp Math.NaN #else 0 / 0 #end;
	public static inline var POSITIVE_INFINITY = #if cpp Math.POSITIVE_INFINITY #else 1. / 0 #end;
	public static inline var NEGATIVE_INFINITY = #if cpp Math.NEGATIVE_INFINITY #else -1. / 0 #end;

	inline public static function invsqrt(v:Float):Float
	{
		//for now, only use normal Math intrinsics
		//TODO optimize for the targets that support it
		return 1 / Math.sqrt(v);
	}
}

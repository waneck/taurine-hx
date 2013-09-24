package taurine.math;

/**
	Implements faster, but lower precision Math intrinsics.
**/
class FastMath
{
	public static inline var NaN = #if cpp Math.NaN #else 0.0 / 0.0 #end;
	public static inline var POSITIVE_INFINITY = #if cpp Math.POSITIVE_INFINITY #else 1. / 0 #end;
	public static inline var NEGATIVE_INFINITY = #if cpp Math.NEGATIVE_INFINITY #else -1. / 0 #end;

  public static inline EPSILON = 0.000001;

	inline public static function invsqrt(v:Float):Float
	{
		//for now, only use normal Math intrinsics
		//TODO optimize for the targets that support it
		return 1 / Math.sqrt(v);
	}

	inline public static function isNaN(v:Float):Bool
	{
		return v != v;
	}

	inline public static function isFinite(v:Float):Bool
	{
		return v * 2 != v || Math.isFinite(v);
	}

  inline public static function abs(f:Float):Float
  {
    return (f < 0) ? -f : f;
  }

  inline public static function sqrt(v:Float):Float
  {
    return Math.sqrt(v); //TODO: optimize
  }
}

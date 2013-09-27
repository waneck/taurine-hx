package taurine.math;

/**
	The radian is the standard unit of angular measure, used in many areas of mathematics.
	An angle's measurement in radians is numerically equal to the length of a corresponding arc of a unit circle, so one radian is just under 57.3 degrees (when the arc length is equal to the radius)
**/
abstract Rad(Float) from Float
{
	public static inline var _toDeg = MacroMath.reduce(180. / Math.PI);
	public static inline var _fromDeg = MacroMath.reduce(Math.PI / 180.);

	public inline function new(f:Float)
	{
		this = f;
	}

	@:from public static inline function fromDegrees(deg:Degrees):Rad
	{
		return new Rad(deg.toFloat() * _fromDeg);
	}

	@:to public inline function toDeg():Degrees
	{
		return new Degrees(this * _toDeg);
	}

	public inline function float():Float
	{
		return this;
	}

	public inline function cos():Float
	{
		return Math.cos(this);
	}

	public inline function sin():Float
	{
		return Math.sin(this);
	}

  inline public function tan():Float
  {
    return Math.tan(this);
  }
}

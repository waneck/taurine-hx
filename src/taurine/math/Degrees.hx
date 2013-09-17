package taurine.math;

abstract Degrees(Float) from Float
{
	public inline function new(f:Float)
	{
		this = f;
	}

	public inline function toFloat():Float
	{
		return this;
	}

	@:to public inline function toRad():Rad
	{
		return Rad.fromDegrees(untyped this);
	}
}

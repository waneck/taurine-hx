/* Copyright (c) 2013, Brandon Jones, Colin MacKenzie IV. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */
package taurine.math;

//This library was ported from the JavaScript library `glMatrix` - copyright above
import haxe.ds.Vector;
import taurine.Single;
using taurine.ds.VectorTools;

/**
	(x,y) vector
**/
@:arrayAccess
@:allow(taurine.math.Vec2Array)
abstract Vec2(Vector<Single>)
{
	/**
		Creates a new Vec2
	**/
	public inline function new(x = 0, y = 0)
	{
		this = VectorTools.create(2);
		this[0] = x; this[1] = y;
	}

	public static inline function mk():Vec2
	{
		return untyped (VectorTools.create(2) : Vector<Single>);
	}

	private inline function t():Vec2 return untyped this; //get `this` as the abstract type

	/**
		Creates a new Vec2 initialized with values from `this` vector
	**/
	public function clone():Vec2
	{
		var out = mk();
		out[0] = this[0];
		out[1] = this[1];
		return out;
	}

	/**
		Copy the value from one Vec2 to another. The parameter `out` cannot be null.
	**/
	public function copy(out:Vec2):Vec2
	{
		out[0] = this[0];
		out[1] = this[1];
		return out;
	}

	/**
		Set the components of a Vec2 to the given values
	**/
	public function set(x:Single, y:Single):Vec2
	{
		this[0] = x;
		this[1] = y;
		return t();
	}

	/**
		Adds two Vec2's.
		If `out` is not null, the result will be stored there; otherwise, the vector will be modified in place
	**/
	public function add(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null) out = t();
		out[0] = t()[0] + b[0];
		out[1] = t()[1] + b[1];

		return out;
	}

	@:op(A+B) public static inline function opAdd(a:Vec2, b:Vec2):Vec2
	{
		return a.add(b, mk());
	}

	/**
		Subtracts vector `b` from `this`.
		If `out` is not null, the result will be stored there; otherwise, the vector will be modified in place
	**/
	public function sub(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null) out = t();
		out[0] = t()[0] - b[0];
		out[1] = t()[1] - b[1];
		return out;
	}

	@:op(A-B) public static inline function opSub(a:Vec2, b:Vec2):Vec2
	{
		return a.sub(b, mk());
	}

	/**
		Multiplies two Vec2's.
		If `out` is not null, the result will be stored there; otherwise, the vector will be modified in place
	**/
	public function mul(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null) out = t();
		out[0] = t()[0] * b[0];
		out[1] = t()[1] * b[1];
		return out;
	}

	@:op(A*B) public static inline function opMul(a:Vec2, b:Vec2):Vec2
	{
		return a.mul(b, mk());
	}

	/**
		Divides two Vec2's
		If `out` is not null, the result will be stored there; otherwise, the vector will be modified in place
	**/
	public function div(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null) out = t();
		out[0] = t()[0] / b[0];
		out[1] = t()[1] / b[1];
		return out;
	}

	@:op(A/B) inline public static function opDiv(a:Vec2, b:Vec2):Vec2
	{
		return a.div(b, mk());
	}

	/**
		Returns the minimum of two Vec2's.
		The `out` parameter is required and cannot be null.
	 **/
	public function min(b:Vec2, out:Vec2):Vec2
	{
		var a0 = t()[0], b0 = b[0], a1 = t()[1], b1 = b[1];
		out[0] = a0 < b0 ? a0 : b0;
		out[1] = a1 < b1 ? a1 : b1;
		return out;
	}

	/**
		Returns the maximum of two Vec2's.
		The `out` parameter is required and cannot be null.
	 **/
	public function max(b:Vec2, out:Vec2):Vec2
	{
		var a0 = t()[0], b0 = b[0], a1 = t()[1], b1 = b[1];
		out[0] = a0 > b0 ? a0 : b0;
		out[1] = a1 > b1 ? a1 : b1;
		return out;
	}

	/**
		Scales a Vec2 by a scalar number
		If `out` is not null, the result will be stored there; otherwise, the vector will be modified in place
	**/
	public function scale(b:Float, ?out:Vec2):Vec2
	{
		if (out != null) out = t();
		out[0] = t()[0] * b;
		out[1] = t()[1] * b;
		return out;
	}

	@:op(A*B) inline public static function opScale(a:Vec2, b:Float):Vec2
	{
		return a.scale(b, mk());
	}

	//scaleAndAdd not added

	public function dist(to:Vec2):Float
	{
		var x = t()[0] - to[0], y = t()[1] - to[1];
		return Math.sqrt(x*x + y*y);
	}

	public function sqrDist(to:Vec2):Float
	{
		var x = to[0] - t()[0], y = to[1] - t()[1];
		return x * x + y * y;
	}

	public function length():Float
	{
		var x = t()[0], y = t()[1];
		return Math.sqrt(x*x + y*y);
	}

	/**
		Negates the components of a Vec2
	**/
	public function negate(?out:Vec2):Vec2
	{
		if(out == null) out = t();
		out[0] = -t()[0];
		out[1] = -t()[1];
		return out;
	}

	@:op(-A) inline public static function opNeg(a:Vec2):Vec2
	{
		return negate(mk());
	}

	/**
		Normalize a Vec2
	**/
	public function normalize(?out:Vec2):Vec2
	{
		if (out == null) out = t();
		var x = t()[0], y = t()[1];
		var len = x*x + y*y;
		if (len > 0)
		{
			len = FastMath.invsqrt(len);
			out[0] = t()[0] * len;
			out[1] = t()[1] * len;
		}
		return out;
	}

	/**
		Dot product of two vectors
	**/
	public function dot(to:Vec2):Float
	{
		return t()[0] * to[0] + t()[1] * b[1];
	}

	/**
		Computes the cross product of two Vec2's
		If `out` is not specified, a new Vec3 will be created
	**/
	public function cross(to:Vec2, ?out:Vec3):Vec2
	{
		if (out == null) out = Vec3.mk();
		var z = t()[0] * to[1] - t()[1] * to[0];
		out[0] = out[1] = 0;
		out[2] = z;
		return out;
	}

	/**
		Performs a linear interpolation between two Vec2's
		If `out` is not specified, `this` vector will be changed in place
	**/
	public function lerp(to:Vec2, t:Float, ?out:Vec2):Vec2
	{
		if (out == null) out = t();
		var ax = t()[0], ay = t()[1];
		out[0] = ax + t * (to[0] - ax);
		out[1] = ay + t * (to[1] - ay);
		return out;
	}


}

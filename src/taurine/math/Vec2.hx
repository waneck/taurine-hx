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

/**
	2 Dimensional Vector
 **/
	@:arrayAccess
abstract Vec2(SingleVector)// to Vec2Array You can only declare from/to with compatible types
{
	public var x(get,set):Single;
	public var y(get,set):Single;

	/**
		Creates a new Vec2
	 **/
	@:extern public inline function new(x=0.,y=0.)
	{
		this = SingleVector.alloc(2);
		this[0] = x; this[1] = y;
	}

	/**
		Creates an empty Vec2
	 **/
	@:extern inline public static function mk():Vec2
	{
		return untyped SingleVector.alloc(2);
	}

	/**
		Tells whether this Vec2 has more than one Vec2 element
	 **/
	@:extern inline public function hasMultiple():Bool
	{
		return this.length > 2;
	}

	@:extern private inline function t():Vec2 return untyped this; //get `this` as the abstract type

	/**
		Clones `this` Vec2
	 **/
	public function clone():Vec2
	{
		var x = this[0], y = this[1];
		var ret = mk();
		ret[0] = x;
		ret[1] = y;

		return ret;
	}

	/**
		Copies `this` Vector to `dest`, and returns `dest`
	 **/
	public function copyTo(dest:Vec2):Vec2
	{
		var x = this[0], y = this[1];

		dest[0] = x;
		dest[1] = y;

		return dest;
	}

	/**
		Reinterpret `this` array as an array (of length 1)
	 **/
	@:to @:extern inline public function array():Vec2Array
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Sets the components of `this` Vec2
		Returns itself
	 **/
	public function set(x:Single, y:Single):Vec2
	{
		this[0] = x;
		this[1] = y;
		return t();
	}

	/**
		Adds `this` Vec2 to `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	public function add(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1];
		var b0 = b[0], b1 = b[1];

		out[0] = x + b0;
		out[1] = y + b1;
		return out;
	}

	@:op(A+B) @:extern inline public static function opAdd(a:Vec2, b:Vec2):Vec2
	{
		return a.add(b,mk());
	}

	/**
		Subtracts `this` Vec2 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	public function sub(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1];
		var b0 = b[0], b1 = b[1];

		out[0] = x - b0;
		out[1] = y - b1;
		return out;
	}

	@:op(A-B) @:extern inline public static function opSub(a:Vec2, b:Vec2):Vec2
	{
		return a.sub(b,mk());
	}

	/**
		Multiplies `this` Vec2 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	public function mul(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1];
		var b0 = b[0], b1 = b[1];

		out[0] = x * b0;
		out[1] = y * b1;
		return out;
	}

	@:op(A*B) @:extern inline public static function opMul(a:Vec2, b:Vec2):Vec2
	{
		return a.mul(b,mk());
	}

	/**
		Divides `this` Vec2 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	public function div(b:Vec2, ?out:Vec2):Vec2
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1];
		var b0 = b[0], b1 = b[1];

		out[0] = x / b0;
		out[1] = y / b1;
		return out;
	}

	@:op(A/B) @:extern inline public static function opDiv(a:Vec2, b:Vec2):Vec2
	{
		return a.div(b,mk());
	}

	/**
		Returns the maximum of two vec4's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	@:extern inline public function max(b:Vec2, ?out:Vec2):Vec2
	{
		return Vec2Array.maxFrom(this,0,b,0,out,0).first();
	}

	/**
		Returns the minimum of two vec4's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	@:extern inline public function min(b:Vec2, ?out:Vec2):Vec2
	{
		return Vec2Array.minFrom(this,0,b,0,out,0).first();
	}

	/**
		Scales a Vec2 by a scalar number

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	@:extern inline public function scale(scalar:Single, ?out:Vec2):Vec2
	{
		return Vec2Array.scale(this,0,scalar,out,0).first();
	}

	@:op(A*B) @:extern inline public static function opMulScalar(a:Vec2, b:Single):Vec2
	{
		return a.scale(b,mk());
	}

	@:op(A*B) @:extern inline public static function opMulScalar_1(b:Single, a:Vec2):Vec2
	{
		return a.scale(b,mk());
	}

	/**
		Calculates the euclidian distance between two Vec2's
	 **/
	@:extern inline public function dist(b:Vec2):Float
	{
		return Vec2Array.dist(this, 0, b, 0);
	}

	/**
		Calculates the squared euclidian distance between two Vec2's
	 **/
	@:extern inline public function sqrdist(b:Vec2):Float
	{
		return Vec2Array.sqrdist(this,0,b,0);
	}

	/**
		Calculates the length of a `Vec2`
	 **/
	public function length():Float
	{
		var x = this[0], y = this[1];
		return FastMath.sqrt(x*x + y*y);
	}

	/**
		Calculates the squared length of a `Vec2`
	 **/
	public function sqrlen():Float
	{
		var x = this[0], y = this[1];
		return (x*x + y*y);
	}

	/**
		Negates the components of a Vec2

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	@:extern inline public function neg(?out:Vec2):Vec2
	{
		return Vec2Array.neg(this,0,out,0).first();
	}

	@:op(-A) @:extern inline public static function opNeg(v:Vec2):Vec2
	{
		return v.neg(mk());
	}

	/**
		Normalize a Vec2

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	@:extern inline public function normalize(?out:Vec2):Vec2
	{
		return Vec2Array.normalize(this,0,out,0).first();
	}

	/**
		Calculates the dot product of two Vec2's
	 **/
	public function dot(b:Vec2):Float
	{
		var x = this[0], y = this[1];
		return b[0] * x + b[1] * y;
	}

	/**
		Performs a linear interpolation between two Vec2's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec2`
	 **/
	public function lerp(to:Vec2, amount:Float, ?out:Vec2):Vec2
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1];
		var bx = to[0], by = to[1];

		out[0] = x + amount * (bx - x);
		out[1] = y + amount * (by - y);
		return out;
	}

	/**
		Transforms the `Vec2` with a `Mat2`

		If `out` is null, it will implicitly be considered itself;
		If `outIndex` is null, it will be considered to be the same as `index`.
		Returns the changed `Vec2`
	 **/
	// @:extern inline public function transformMat2(m:Mat2Array, ?out:Vec2):Vec2
	// {
	// 	return Vec2Array.transformMat2(this,0,m,0,out,0).first();
	// }

	/**
		Transforms the `Vec2` with a `Mat2D`

		If `out` is null, it will implicitly be considered itself;
		If `outIndex` is null, it will be considered to be the same as `index`.
		Returns the changed `Vec2`
	 **/
	@:extern inline public function transformMat2D(m:Mat2DArray, ?out:Vec2):Vec2
	{
		return Vec2Array.transformMat2D(this,0,m,0,out,0).first();
	}

	/**
		Transforms the `Vec2` with a `Mat3`
		3rd vector component is implicitly `1`

		If `out` is null, it will implicitly be considered itself;
		If `outIndex` is null, it will be considered to be the same as `index`.
		Returns the changed `Vec2`
	 **/
	@:extern inline public function transformMat3(m:Mat3Array, ?out:Vec2):Vec2
	{
		return Vec2Array.transformMat3(this,0,m,0,out,0).first();
	}

	/**
		Transforms the `Vec2` with a `Mat4`
		3rd and 4th vector components are implicitly `1`

		If `out` is null, it will implicitly be considered itself;
		If `outIndex` is null, it will be considered to be the same as `index`.
		Returns the changed `Vec2`
	 **/
	public function transformMat4(m:Mat4Array, ?out:Vec2):Vec2
	{
		return Vec2Array.transformMat4(this,0,m,0,out,0).first();
	}

	public function toString():String
	{
		var buf = new StringBuf();
		{
			buf.add('vec4(');
			var fst = true;
			for (j in 0...2)
			{
				if (fst) fst = false; else buf.add(", ");
				buf.add(this[ j ]);
			}
			buf.add(")");
		}

		return buf.toString();
	}

	/**
		Returns true if the vectors are equal
		**/
	public function eq(b:Vec2):Bool
	{
		return this == b.getData() || (this != null && b != null && b[0] == this[0] && b[1] == this[1]);
	}

	@:op(A==B) @:extern inline public static function opEq(a:Vec2, b:Vec2):Bool
	{
		return a.eq(b);
	}

	@:op(A!=B) @:extern inline public static function opNEq(a:Vec2, b:Vec2):Bool
	{
		return !a.eq(b);
	}

	@:arrayAccess inline public function getRaw(idx:Int):Single
	{
		return this[idx];
	}

	@:arrayAccess inline public function setRaw(idx:Int, v:Single):Single
	{
		return this[idx] = v;
	}

	//boilerplate
	@:extern inline private function get_x():Single return this[0];
	@:extern inline private function set_x(val:Single):Single return this[0] = val;
	@:extern inline private function get_y():Single return this[1];
	@:extern inline private function set_y(val:Single):Single return this[1] = val;
}

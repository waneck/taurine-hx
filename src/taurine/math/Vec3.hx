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
	3 Dimensional Vector
 **/
	@:arrayAccess
abstract Vec3(SingleVector) //to Vec3Array
{
	public var x(get,set):Single;
	public var y(get,set):Single;
	public var z(get,set):Single;

	/**
		Creates a new Vec3
	 **/
	@:extern public inline function new(x=0.,y=0.,z=0.)
	{
		this = SingleVector.alloc(3);
		this[0] = x; this[1] = y; this[2] = z;
	}

	/**
		Creates an empty Vec3
	 **/
	@:extern inline public static function mk():Vec3
	{
		return untyped SingleVector.alloc(3);
	}

	/**
		Tells whether this Vec3 has more than one Vec3 element
	 **/
	@:extern inline public function hasMultiple():Bool
	{
		return this.length > 3;
	}

	@:extern private inline function t():Vec3 return untyped this; //get `this` as the abstract type

	/**
		Clones `this` Vec3
	 **/
	public function clone():Vec3
	{
		var x = this[0], y = this[1], z = this[2];
		var ret = mk();
		ret[0] = x;
		ret[1] = y;
		ret[2] = z;

		return ret;
	}

	/**
		Copies `this` Vector to `dest`, and returns `dest`
	 **/
	public function copyTo(dest:Vec3):Vec3
	{
		var x = this[0], y = this[1], z = this[2];

		dest[0] = x;
		dest[1] = y;
		dest[2] = z;

		return dest;
	}

	/**
		Reinterpret `this` array as an array (of length 1)
	 **/
	@:to @:extern inline public function array():Vec3Array
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Sets the components of `this` Vec3
		Returns itself
	 **/
	public function set(x:Single, y:Single, z:Single):Vec3
	{
		this[0] = x;
		this[1] = y;
		this[2] = z;
		return t();
	}

	/**
		Adds `this` Vec3 to `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	public function add(b:Vec3, ?out:Vec3):Vec3
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2];
		var b0 = b[0], b1 = b[1], b2 = b[2];

		out[0] = x + b0;
		out[1] = y + b1;
		out[2] = z + b2;
		return out;
	}

	@:op(A+B) @:extern inline public static function opAdd(a:Vec3, b:Vec3):Vec3
	{
		return a.add(b,mk());
	}

	/**
		Subtracts `this` Vec3 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	public function sub(b:Vec3, ?out:Vec3):Vec3
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2];
		var b0 = b[0], b1 = b[1], b2 = b[2];

		out[0] = x - b0;
		out[1] = y - b1;
		out[2] = z - b2;
		return out;
	}

	@:op(A-B) @:extern inline public static function opSub(a:Vec3, b:Vec3):Vec3
	{
		return a.sub(b,mk());
	}

	/**
		Multiplies `this` Vec3 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	public function mul(b:Vec3, ?out:Vec3):Vec3
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2];
		var b0 = b[0], b1 = b[1], b2 = b[2];

		out[0] = x * b0;
		out[1] = y * b1;
		out[2] = z * b2;
		return out;
	}

	@:op(A*B) @:extern inline public static function opMul(a:Vec3, b:Vec3):Vec3
	{
		return a.mul(b,mk());
	}

	/**
		Divides `this` Vec3 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	public function div(b:Vec3, ?out:Vec3):Vec3
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2];
		var b0 = b[0], b1 = b[1], b2 = b[2];

		out[0] = x / b0;
		out[1] = y / b1;
		out[2] = z / b2;
		return out;
	}

	@:op(A/B) @:extern inline public static function opDiv(a:Vec3, b:Vec3):Vec3
	{
		return a.div(b,mk());
	}

	/**
		Returns the maximum of two vec4's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function max(b:Vec3, ?out:Vec3):Vec3
	{
		return Vec3Array.maxFrom(this,0,b,0,out,0).first();
	}

	/**
		Returns the minimum of two vec4's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function min(b:Vec3, ?out:Vec3):Vec3
	{
		return Vec3Array.minFrom(this,0,b,0,out,0).first();
	}

	/**
		Scales a Vec3 by a scalar number

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function scale(scalar:Single, ?out:Vec3):Vec3
	{
		return Vec3Array.scale(this,0,scalar,out,0).first();
	}

	@:op(A*B) @:extern inline public static function opMulScalar(a:Vec3, b:Single):Vec3
	{
		return a.scale(b,mk());
	}

	@:op(A*B) @:extern inline public static function opMulScalar_1(b:Single, a:Vec3):Vec3
	{
		return a.scale(b,mk());
	}

	/**
		Calculates the euclidian distance between two Vec3's
	 **/
	@:extern inline public function dist(b:Vec3):Float
	{
		return Vec3Array.dist(this, 0, b, 0);
	}

	/**
		Calculates the squared euclidian distance between two Vec3's
	 **/
	@:extern inline public function sqrdist(b:Vec3):Float
	{
		return Vec3Array.sqrdist(this,0,b,0);
	}

	/**
		Calculates the length of a `Vec3`
	 **/
	public function length():Float
	{
		var x = this[0], y = this[1], z = this[2];
		return FastMath.sqrt(x*x + y*y + z*z);
	}

	/**
		Calculates the squared length of a `Vec3`
	 **/
	public function sqrlen():Float
	{
		var x = this[0], y = this[1], z = this[2];
		return (x*x + y*y + z*z);
	}

	/**
		Negates the components of a Vec3

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function neg(?out:Vec3):Vec3
	{
		return Vec3Array.neg(this,0,out,0).first();
	}

	@:op(-A) @:extern inline public static function opNeg(v:Vec3):Vec3
	{
		return v.neg(mk());
	}

	/**
		Normalize a Vec3

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function normalize(?out:Vec3):Vec3
	{
		return Vec3Array.normalize(this,0,out,0).first();
	}

	/**
		Calculates the dot product of two Vec3's
	 **/
	public function dot(b:Vec3):Float
	{
		var x = this[0], y = this[1], z = this[2];
		return b[0] * x + b[1] * y + b[2] * z;
	}

	/**
		Performs a linear interpolation between two Vec3's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	public function lerp(to:Vec3, amount:Float, ?out:Vec3):Vec3
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2];
		var bx = to[0], by = to[1], bz = to[2];

		out[0] = x + amount * (bx - x);
		out[1] = y + amount * (by - y);
		out[2] = z + amount * (bz - z);
		return out;
	}

	/**
		Transforms the `Vec3` with a `Mat4`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function transformMat4(m:Mat4, ?out:Vec3):Vec3
	{
		return Vec3Array.transformMat4(this,0,m,0,out,0).first();
	}

	/**
		Transforms the `Vec3` with a `Mat3`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function transformMat3(m:Mat3, ?out:Vec3):Vec3
	{
		return Vec3Array.transformMat3(this,0,m,0,out,0).first();
	}

	/**
		Transforms the `Vec3` with a `Quat`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec3`
	 **/
	@:extern inline public function transformQuat(q:Quat, ?out:Vec3):Vec3
	{
		return Vec3Array.transformQuat(this,0,q,0,out,0).first();
	}

	/**
		Returns true if the vectors are equal
	 **/
	public function eq(b:Vec3):Bool
	{
		if (this == b.getData())
			return true;
		else if (this == null || b == null)
			return false;
		for (i in 0...3)
		{
			var v = this[i] - b[i];
			if (v != 0 && (v < 0 && v < -FastMath.EPSILON) || (v > FastMath.EPSILON)) //this != b
				return false;
		}
		return true;
	}

	@:op(A==B) @:extern inline public static function opEq(a:Vec3, b:Vec3):Bool
	{
		return a.eq(b);
	}

	@:op(A!=B) @:extern inline public static function opNEq(a:Vec3, b:Vec3):Bool
	{
		return !a.eq(b);
	}

	public function toString():String
	{
		var buf = new StringBuf();
		{
			buf.add('vec3(');
			var fst = true;
			for (j in 0...3)
			{
				if (fst) fst = false; else buf.add(", ");
				buf.add(this[ j ]);
			}
			buf.add(")");
		}

		return buf.toString();
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
	@:extern inline private function get_z():Single return this[2];
	@:extern inline private function set_z(val:Single):Single return this[2] = val;
}

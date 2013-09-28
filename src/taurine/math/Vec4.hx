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
	4 Dimensional Vector
 **/
	@:arrayAccess
abstract Vec4(SingleVector) //to Vec4Array
{
	public var x(get,set):Single;
	public var y(get,set):Single;
	public var z(get,set):Single;
	public var w(get,set):Single;

	/**
		Creates a new Vec4
	 **/
	@:extern public inline function new(x=0.,y=0.,z=0.,w=0.)
	{
		this = SingleVector.alloc(4);
		this[0] = x; this[1] = y; this[2] = z; this[3] = w;
	}

	/**
		Creates an empty Vec4
	 **/
	@:extern inline public static function mk():Vec4
	{
		return untyped SingleVector.alloc(4);
	}

	/**
		Tells whether this Vec4 has more than one Vec4 element
	 **/
	@:extern inline public function hasMultiple():Bool
	{
		return this.length > 4;
	}

	@:extern private inline function t():Vec4 return untyped this; //get `this` as the abstract type

	/**
		Clones `this` Vec4
	 **/
	public function clone():Vec4
	{
		var x = this[0], y = this[1], z = this[2], w = this[3];
		var ret = mk();
		ret[0] = x;
		ret[1] = y;
		ret[2] = z;
		ret[3] = w;

		return ret;
	}

	/**
		Copies `this` Vector to `dest`, and returns `dest`
	 **/
	public function copyTo(dest:Vec4):Vec4
	{
		var x = this[0], y = this[1], z = this[2], w = this[3];

		dest[0] = x;
		dest[1] = y;
		dest[2] = z;
		dest[3] = w;

		return dest;
	}

	/**
		Reinterpret `this` array as an array (of length 1)
	 **/
	@:to @:extern inline public function array():Vec4Array
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Sets the components of `this` Vec4
		Returns itself
	 **/
	public function set(x:Single, y:Single, z:Single, w:Single):Vec4
	{
		this[0] = x;
		this[1] = y;
		this[2] = z;
		this[3] = w;
		return t();
	}

	/**
		Adds `this` Vec4 to `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	public function add(b:Vec4, ?out:Vec4):Vec4
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2], w = this[3];
		var b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3];

		out[0] = x + b0;
		out[1] = y + b1;
		out[2] = z + b2;
		out[3] = w + b3;
		return out;
	}

	@:op(A+B) @:extern inline public static function opAdd(a:Vec4, b:Vec4):Vec4
	{
		return a.add(b,mk());
	}

	/**
		Subtracts `this` Vec4 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	public function sub(b:Vec4, ?out:Vec4):Vec4
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2], w = this[3];
		var b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3];

		out[0] = x - b0;
		out[1] = y - b1;
		out[2] = z - b2;
		out[3] = w - b3;
		return out;
	}

	@:op(A-B) @:extern inline public static function opSub(a:Vec4, b:Vec4):Vec4
	{
		return a.sub(b,mk());
	}

	/**
		Multiplies `this` Vec4 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	public function mul(b:Vec4, ?out:Vec4):Vec4
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2], w = this[3];
		var b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3];

		out[0] = x * b0;
		out[1] = y * b1;
		out[2] = z * b2;
		out[3] = w * b3;
		return out;
	}

	@:op(A*B) @:extern inline public static function opMul(a:Vec4, b:Vec4):Vec4
	{
		return a.mul(b,mk());
	}

	/**
		Divides `this` Vec4 and `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	public function div(b:Vec4, ?out:Vec4):Vec4
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2], w = this[3];
		var b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3];

		out[0] = x / b0;
		out[1] = y / b1;
		out[2] = z / b2;
		out[3] = w / b3;
		return out;
	}

	@:op(A/B) @:extern inline public static function opDiv(a:Vec4, b:Vec4):Vec4
	{
		return a.div(b,mk());
	}

	/**
		Returns the maximum of two vec4's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	@:extern inline public function max(b:Vec4, ?out:Vec4):Vec4
	{
		return Vec4Array.maxFrom(this,0,b,0,out,0).first();
	}

	/**
		Returns the minimum of two vec4's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	@:extern inline public function min(b:Vec4, ?out:Vec4):Vec4
	{
		return Vec4Array.minFrom(this,0,b,0,out,0).first();
	}

	/**
		Scales a Vec4 by a scalar number

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	@:extern inline public function scale(scalar:Single, ?out:Vec4):Vec4
	{
		return Vec4Array.scale(this,0,scalar,out,0).first();
	}

	@:op(A*B) @:extern inline public static function opMulScalar(a:Vec4, b:Single):Vec4
	{
		return a.scale(b,mk());
	}

	@:op(A*B) @:extern inline public static function opMulScalar_1(b:Single, a:Vec4):Vec4
	{
		return a.scale(b,mk());
	}

	/**
		Calculates the euclidian distance between two Vec4's
	 **/
	@:extern inline public function dist(b:Vec4):Float
	{
		return Vec4Array.dist(this, 0, b, 0);
	}

	/**
		Calculates the squared euclidian distance between two Vec4's
	 **/
	@:extern inline public function sqrdist(b:Vec4):Float
	{
		return Vec4Array.sqrdist(this,0,b,0);
	}

	/**
		Calculates the length of a `Vec4`
	 **/
	public function length():Float
	{
		var x = this[0], y = this[1], z = this[2], w = this[3];
		return FastMath.sqrt(x*x + y*y + z*z + w*w);
	}

	/**
		Calculates the squared length of a `Vec4`
	 **/
	public function sqrlen():Float
	{
		var x = this[0], y = this[1], z = this[2], w = this[3];
		return (x*x + y*y + z*z + w*w);
	}

	/**
		Negates the components of a Vec4

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	@:extern inline public function neg(?out:Vec4):Vec4
	{
		return Vec4Array.neg(this,0,out,0).first();
	}

	@:op(-A) @:extern inline public static function opNeg(v:Vec4):Vec4
	{
		return v.neg(mk());
	}

	/**
		Normalize a Vec4

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	@:extern inline public function normalize(?out:Vec4):Vec4
	{
		return Vec4Array.normalize(this,0,out,0).first();
	}

	/**
		Calculates the dot product of two Vec4's
	 **/
	public function dot(b:Vec4):Float
	{
		var x = this[0], y = this[1], z = this[2], w = this[3];
		return b[0] * x + b[1] * y + b[2] * z + b[3] * w;
	}

	/**
		Performs a linear interpolation between two Vec4's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	public function lerp(to:Vec4, amount:Float, ?out:Vec4):Vec4
	{
		if (out == null)
			out = t();
		var x = this[0], y = this[1], z = this[2], w = this[3];
		var bx = to[0], by = to[1], bz = to[2], bw = to[3];

		out[0] = x + amount * (bx - x);
		out[1] = y + amount * (by - y);
		out[2] = z + amount * (bz - z);
		out[3] = w + amount * (bw - w);
		return out;
	}

	/**
		Transforms the `Vec4` with a `Mat4`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	@:extern inline public function transformMat4(m:Mat4, ?out:Vec4):Vec4
	{
		return Vec4Array.transformMat4(this,0,m,0,out,0).first();
	}

	/**
		Transforms the `Vec4` with a `Quat`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Vec4`
	 **/
	@:extern inline public function transformQuat(q:Quat, ?out:Vec4):Vec4
	{
		return Vec4Array.transformQuat(this,0,q,0,out,0).first();
	}

	/**
		Returns true if the vectors are equal
	 **/
	public function eq(b:Vec4):Bool
	{
		if (this == b.getData())
			return true;
		else if (this == null || b == null)
			return false;
		for (i in 0...4)
		{
			var v = this[i] - b[i];
			if (v != 0 && (v < 0 && v < -FastMath.EPSILON) || (v > FastMath.EPSILON)) //this != b
				return false;
		}
		return true;
	}

	@:op(A==B) @:extern inline public static function opEq(a:Vec4, b:Vec4):Bool
	{
		return a.eq(b);
	}

	@:op(A!=B) @:extern inline public static function opNEq(a:Vec4, b:Vec4):Bool
	{
		return !a.eq(b);
	}

	public function toString():String
	{
		var buf = new StringBuf();
		{
			buf.add('vec4(');
			var fst = true;
			for (j in 0...4)
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
	@:extern inline private function get_w():Single return this[3];
	@:extern inline private function set_w(val:Single):Single return this[3] = val;
}

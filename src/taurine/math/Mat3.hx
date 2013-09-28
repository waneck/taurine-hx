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
	3x3 Matrix
 **/
	@:arrayAccess
abstract Mat3(SingleVector) //to Mat3Array
{
	public var a00(get,set):Single;
	public var a01(get,set):Single;
	public var a02(get,set):Single;
	public var a10(get,set):Single;
	public var a11(get,set):Single;
	public var a12(get,set):Single;
	public var a20(get,set):Single;
	public var a21(get,set):Single;
	public var a22(get,set):Single;

	/**
		Creates a new identity Mat3
	 **/
	@:extern public inline function new()
	{
		this = SingleVector.alloc(9);
		this[0] = this[4] = this[8] = 1;
#if neko
		this[1] = this[2] = this[3] =
			this[5] = this[6] = this[7] = 0;
#end
	}

	/**
		Creates an empty Mat3
	 **/
	@:extern inline public static function mk():Mat3
	{
		return untyped SingleVector.alloc(9);
	}

	/**
		Returns the value of `this` Matrix, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function matval(row:Int, column:Int):Single
	{
		return this[(row*3 + column)];
	}

	/**
		Sets the value of `this` Matrix, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function setMatval(row:Int, column:Int, v:Single):Single
	{
		return this[(row*3 + column)] = v;
	}

	/**
		Tells whether this Mat3 has more than one Mat3 element
	 **/
	@:extern inline public function hasMultiple():Bool
	{
		return this.length > 9;
	}

	/**
		Clones the current Mat3
	 **/
	public function clone():Mat3
	{
		var ret = mk();
		for (i in 0...9) ret[i] = this[i];
		return ret;
	}

	/**
		Copies `this` matrix to `dest`, and returns `dest`
	 **/
	public function copyTo(dest:Mat3):Mat3
	{
		for (i in 0...9)
			dest[i] = this[i];
		return dest;
	}

	@:extern private inline function t():Mat3 return untyped this; //get `this` as the abstract type

	/**
		Reinterpret `this` Matrix as an array (of length 1)
	 **/
	@:to @:extern inline public function array():Mat3Array
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Set the Mat3 to the identity matrix.

		Returns itself
	 **/
	public function identity():Mat3
	{
		this[0] = this[4] = this[8] = 1;
		this[1] = this[2] = this[3] =
			this[5] = this[6] = this[7] = 0;
		return t();
	}

	/**
		Transpose the values of a Mat3 and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3`
	 **/
	@:extern inline public function transpose(?out:Mat3):Mat3
	{
		return Mat3Array.transpose(this,0,out,0).first();
	}

	/**
		Inverts current matrix and stores the value at `out` matrix

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3`; If the operation fails, returns `null`
	 **/
	@:extern inline public function invert(?out:Mat3):Mat3
	{
		return Mat3Array.invert(this, 0, out, 0).first();
	}

	/**
		Calculates the adjugate of a Mat3

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3`;
	 **/
	@:extern inline public function adjoint(?out:Mat3):Mat3
	{
		return Mat3Array.adjoint(this,0,out,0).first();
	}

	/**
		Calculates de determinant of the Mat3
	 **/
	@:extern inline public function determinant():Float
	{
		return Mat3Array.determinant(this,0);
	}

	/**
		Multiplies current matrix with matrix `b`,
		and stores the value on `out` matrix

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3`
	 **/
	@:extern inline public function mul(b:Mat3, ?out:Mat3):Mat3
	{
		return Mat3Array.mul(this, 0, b, 0, out, 0).first();
	}

	@:op(A*B) @:extern inline public static function opMult(a:Mat3, b:Mat3):Mat3
	{
		return Mat3Array.mul(a.getData(),0,b,0,mk(),0).first();
	}

	/**
		Translates the mat4 with `x`, `y`.

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3`
	 **/
	@:extern inline public function translate(x:Single, y:Single, ?out:Mat3):Mat3
	{
		return Mat3Array.translate(this,0,x,y,out,0).first();
	}

	/**
		Translates the mat4 with the `vec` Vec2
		@see Mat3#translate
	 **/
	@:extern inline public function translatev(vec:Vec2, ?out:Mat3):Mat3
	{
		return translate(vec[0],vec[1],out);
	}

	/**
		Scales the mat4 by `x`, `y`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3`
	 **/
	@:extern inline public function scale(x:Single, y:Single, ?out:Mat3):Mat3
	{
		return Mat3Array.scale(this,0,x,y,out,0).first();
	}

	@:extern inline public function scalev(vec:Vec2, ?out:Mat3):Mat3
	{
		return scale(vec[0],vec[1],out);
	}

	/**
		Rotates `this` matrix by the given angle at the (`x`, `y`) vector

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3`
	 **/
	@:extern inline public function rotate(angle:Rad, x:Single, y:Single, ?out:Mat3):Mat3
	{
		return Mat3Array.rotate(this,0,angle,x,y,out,0).first();
	}

	@:extern inline public function rotate_v(angle:Rad, vec:Vec2, ?out:Mat3):Mat3
	{
		return rotate(angle,vec[0],vec[1],out);
	}

	/**
		Copies the values from a Mat2D into a Mat3
	 **/
	@:extern inline public function fromMat2D(b:Mat2D):Mat3
	{
		return Mat3Array.fromMat2D(this,0,b,0).first();
	}

	/**
		Copies the upper-left 3x3 values into the given mat3
	**/
	@:extern inline public function fromMat4(b:Mat4Array):Mat3
	{
		return Mat3Array.fromMat4(this,0,b,0).first();
	}

	/**
		Calculates a 4x4 matrix from the quaternion `quat` at `quatIndex`, and
		stores the result on `this` matrix

		Returns `this` matrix array
	 **/
	@:extern inline public function fromQuat(quat:QuatArray):Mat3
	{
		return Mat3Array.fromQuat(this,0,quat,0).first();
	}

	/**
		Calculates a 3x3 normal matrix (transpose inverse) from the 4x4 matrix
	 **/
	@:extern inline public function normalFromMat4(b:Mat4):Mat3
	{
		return Mat3Array.normalFromMat4(this,0,b,0).first();
	}

	public function toString():String
	{
		var buf = new StringBuf();
		var support = [], maxn = 0;
		buf.add('mat3(');
		for (i in 0...9)
		{
			var s = support[ i ] = this[ i ] + "";
			if (s.length > maxn) maxn = s.length;
		}

		for (j in 0...3)
		{
			buf.add('\n     ');
			for (k in 0...3)
			{
				buf.add(StringTools.rpad(support[ (j * 3) + k ], " ", maxn));
				buf.add(", ");
			}
		}
		buf.add(")");

		return buf.toString();
	}

	public function eq(b:Mat3):Bool
	{
		if (this == b.getData())
			return true;
		else if (this == null || b == null)
			return false;
		for (i in 0...9)
		{
			var v = this[i] - b[i];
			if (v != 0 && (v < 0 && v < -FastMath.EPSILON) || (v > FastMath.EPSILON)) //this != b
				return false;
		}
		return true;
	}

	@:op(A==B) @:extern inline public static function opEq(a:Mat3, b:Mat3):Bool
	{
		return a.eq(b);
	}

	@:op(A!=B) @:extern inline public static function opNEq(a:Mat3, b:Mat3):Bool
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
	@:extern inline private function get_a00():Single return this[0];
	@:extern inline private function set_a00(val:Single):Single return this[0] = val;
	@:extern inline private function get_a01():Single return this[1];
	@:extern inline private function set_a01(val:Single):Single return this[1] = val;
	@:extern inline private function get_a02():Single return this[2];
	@:extern inline private function set_a02(val:Single):Single return this[2] = val;
	@:extern inline private function get_a10():Single return this[3];
	@:extern inline private function set_a10(val:Single):Single return this[3] = val;
	@:extern inline private function get_a11():Single return this[4];
	@:extern inline private function set_a11(val:Single):Single return this[4] = val;
	@:extern inline private function get_a12():Single return this[5];
	@:extern inline private function set_a12(val:Single):Single return this[5] = val;
	@:extern inline private function get_a20():Single return this[6];
	@:extern inline private function set_a20(val:Single):Single return this[6] = val;
	@:extern inline private function get_a21():Single return this[7];
	@:extern inline private function set_a21(val:Single):Single return this[7] = val;
	@:extern inline private function get_a22():Single return this[8];
	@:extern inline private function set_a22(val:Single):Single return this[8] = val;
}

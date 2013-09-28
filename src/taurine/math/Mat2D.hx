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
	2x3 Matrix
	A Mat2D contains six elements defined as:
	```
	[a, b,
	 c, d,
	 tx,ty]
	```

	This is a short form for the 3x3 matrix:
	```
	[a, b, 0
	 c, d, 0
	 tx,ty,1]
	```
	The last column is ignored so the array is shorter and operations are faster
 **/
	@:arrayAccess
abstract Mat2D(SingleVector) //to Mat2DArray
{
	public var a(get,set):Single;
	public var b(get,set):Single;
	public var c(get,set):Single;
	public var d(get,set):Single;
	public var tx(get,set):Single;
	public var ty(get,set):Single;

	/**
		Creates a new identity Mat2D
	 **/
	@:extern public inline function new()
	{
		this = SingleVector.alloc(6);
		this[0] = this[3] = 1;
#if neko
		this[1] = this[2] = this[4] =	this[5] = 0;
#end
	}

	/**
		Creates an empty Mat2D
	 **/
	@:extern inline public static function mk():Mat2D
	{
		return untyped SingleVector.alloc(6);
	}

	/**
		@see taurine.math.Geom.mat2d
	 **/
	macro public static function mat2d(exprs:Array<haxe.macro.Expr>):haxe.macro.Expr.ExprOf<Mat2DArray>
	{
		return Geom.mat2d_internal(exprs);
	}

	/**
		Returns the value of `this` Matrix, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function matval(row:Int, column:Int):Single
	{
		return this[(row << 1) + column];
	}

	/**
		Sets the value of `this` Matrix, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function setMatval(row:Int, column:Int, v:Single):Single
	{
		return this[(row << 1) + column] = v;
	}

	/**
		Tells whether this Mat2D has more than one Mat2D element
	 **/
	@:extern inline public function hasMultiple():Bool
	{
		return this.length > 6;
	}

	/**
		Clones the current Mat2D
	 **/
	public function clone():Mat2D
	{
		var ret = mk();
		for (i in 0...6) ret[i] = this[i];
		return ret;
	}

	/**
		Copies `this` matrix to `dest`, and returns `dest`
	 **/
	public function copyTo(dest:Mat2D):Mat2D
	{
		for (i in 0...6)
			dest[i] = this[i];
		return dest;
	}

	@:extern private inline function t():Mat2D return untyped this; //get `this` as the abstract type

	/**
		Reinterpret `this` Matrix as an array (of length 1)
	 **/
	@:to @:extern inline public function array():Mat2DArray
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Set the Mat2D at `index` to the identity matrix.

		Returns itself
	 **/
	public function identity():Mat2D
	{
		this[0] = this[3] = 1;
		this[1] = this[2] = this[4] =	this[5] = 0;
		return t();
	}

	/**
		Inverts current matrix and stores the value at `out` matrix

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2D`; If the operation fails, returns `null`
	 **/
	@:extern inline public function invert(?out:Mat2D):Mat2D
	{
		return Mat2DArray.invert(this, 0, out, 0).first();
	}

	/**
		Calculates de determinant of the Mat2D
	 **/
	@:extern inline public function determinant():Float
	{
		return Mat2DArray.determinant(this,0);
	}

	@:extern inline public function det():Float
	{
		return determinant();
	}

	/**
		Multiplies current matrix with matrix `b`,
		and stores the value on `out` matrix

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2D`
	 **/
	@:extern inline public function mul(b:Mat2D, ?out:Mat2D):Mat2D
	{
		return Mat2DArray.mul(this, 0, b, 0, out, 0).first();
	}

	@:op(A*B) @:extern inline public static function opMult(a:Mat2D, b:Mat2D):Mat2D
	{
		return Mat2DArray.mul(a.getData(),0,b,0,mk(),0).first();
	}

	/**
		Translates the mat4 with `x`, `y`.

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2D`
	 **/
	@:extern inline public function translate(x:Single, y:Single, ?out:Mat2D):Mat2D
	{
		return Mat2DArray.translate(this,0,x,y,out).first();
	}

	/**
		Translates the mat4 with the `vec` Vec2
		@see Mat2D#translate
	 **/
	@:extern inline public function translatev(vec:Vec2, ?out:Mat2D):Mat2D
	{
		return translate(vec[0],vec[1],out);
	}

	/**
		Scales the mat4 by `x`, `y`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2D`
	 **/
	@:extern inline public function scale(x:Single, y:Single, ?out:Mat2D):Mat2D
	{
		return Mat2DArray.scale(this,0,x,y,out,0).first();
	}

	@:extern inline public function scalev(vec:Vec2, ?out:Mat2D):Mat2D
	{
		return scale(vec[0],vec[1],out);
	}

	/**
		Rotates `this` matrix by the given angle at the (`x`, `y`) vector

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2D`
	 **/
	@:extern inline public function rotate(angle:Rad, ?out:Mat2D):Mat2D
	{
		return Mat2DArray.rotate(this,0,angle,out,0).first();
	}

	public function toString():String
	{
		var buf = new StringBuf();
		var support = [], maxn = 0;
		buf.add('mat2d(');
		for (i in 0...6)
		{
			var s = support[ i ] = this[ i ] + "";
			if (s.length > maxn) maxn = s.length;
		}

		var fst = true;
		for (j in 0...3)
		{
			buf.add('\n      ');
			for (k in 0...2)
			{
				buf.add(StringTools.rpad(support[ (j * 2) + k ], " ", maxn));
				buf.add(", ");
			}
			buf.add( j == 2 ? "1" : "0");
		}
		buf.add(")");

		return buf.toString();
	}

	public function eq(b:Mat2D):Bool
	{
		if (this == b.getData())
			return true;
		else if (this == null || b == null)
			return false;
		for (i in 0...6)
		{
			var v = this[i] - b[i];
			if (v != 0 && (v < 0 && v < -FastMath.EPSILON) || (v > FastMath.EPSILON)) //this != b
				return false;
		}
		return true;
	}

	@:op(A==B) @:extern inline public static function opEq(a:Mat2D, b:Mat2D):Bool
	{
		return a.eq(b);
	}

	@:op(A!=B) @:extern inline public static function opNEq(a:Mat2D, b:Mat2D):Bool
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
	@:extern inline private function get_a():Single return this[0];
	@:extern inline private function set_a(val:Single):Single return this[0] = val;
	@:extern inline private function get_b():Single return this[1];
	@:extern inline private function set_b(val:Single):Single return this[1] = val;
	@:extern inline private function get_c():Single return this[2];
	@:extern inline private function set_c(val:Single):Single return this[2] = val;
	@:extern inline private function get_d():Single return this[3];
	@:extern inline private function set_d(val:Single):Single return this[3] = val;
	@:extern inline private function get_tx():Single return this[4];
	@:extern inline private function set_tx(val:Single):Single return this[4] = val;
	@:extern inline private function get_ty():Single return this[5];
	@:extern inline private function set_ty(val:Single):Single return this[5] = val;
}

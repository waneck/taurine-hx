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
	3x3 Matrix Array

	WARNING: Unlike all other structures, this array will not be aligned to a power of two;
	Use with care inside a hardware pipeline
 **/
abstract Mat3Array(SingleVector)
{
	/**
		Creates a new Mat3Array with the given size.
		All elements will be 0, and not identity matrices
	 **/
	@:extern public inline function new(len:Int)
	{
		this = SingleVector.alloc(len * 9); //WARNING: because of the storage overhead, access isn't aligned!
	}

	/**
		The number of Mat3 elements contained in this array
	 **/
	public var length(get,never):Int;

	@:extern private inline function get_length():Int
	{
		return Std.int(this.length / 9);
	}

	@:extern private inline function t():Mat3Array return untyped this; //get `this` as the abstract type

	/**
		Reinterpret `this` array as its first `Mat3`
	 **/
	@:extern inline public function first():Mat3
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Returns the `nth` val of `this` Matrix at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function val(index:Int, nth:Int):Single
	{
		return this[index * 9 + nth];
	}

	/**
		Sets the `nth` val of `this` Matrix at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function setVal(index:Int, nth:Int, v:Single):Single
	{
		return this[index * 9 + nth] = v;
	}

	/**
		Returns the value of `this` Matrix at `index`, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function matval(index:Int, row:Int, column:Int):Single
	{
		return this[index * 9 + (row*3 + column)];
	}

	/**
		Sets the value of `this` Matrix at `index`, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function setMatval(index:Int, row:Int, column:Int, v:Single):Single
	{
		return this[index * 9 + (row*3 + column)] = v;
	}

	/**
		Creates a copy of the current Mat3Array and returns it
	 **/
	public function copy():Mat3Array
	{
		var len = this.length;
		var ret = new Mat3Array(Std.int(len / 9));
		SingleVector.blit(this, 0, ret.getData(), 0, len);
		return ret;
	}

	/**
		Clones the matrix at `index`
	**/
	public function cloneAt(index:Int):Mat3
	{
		var out = Mat3.mk();
		index *= 9;
		for (i in 0...9)
			out[i] = this[index+i];
		return out;
	}

	/**
		Copies Mat3 at `index` to `out`, at `outIndex`
		Returns `out` object
	 **/
	public function copyTo(index:Int, out:Mat3Array, outIndex:Int)
	{
		index *= 9; outIndex *= 9;
		for (i in 0...9)
			out[outIndex + i] = this[index + i];
		return out;
	}

	/**
		Set the Mat3 at `index` to the identity matrix.

		Returns itself
	 **/
	public function identity(index:Int):Mat3Array
	{
		index = index * 9;
		this[index] = this[index+4] = this[index+8] = 1;
		this[index+1] = this[index+2] = this[index+3] =
			this[index+5] = this[index+6] = this[index+7] = 0;
		return t();
	}

	/**
		Transpose the values of a Mat3 at `index` and stores the result at `out` (at `outIndex`).

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3Array`
	 **/
	@:extern public inline function transpose(index:Int, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return transpose_impl(index, out, outIndex);
	}

	private function transpose_impl(index:Int, out:Mat3Array, outIndex:Int):Mat3Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		outIndex = outIndex * 9;
		index *= 9;

		if (outIndex == index && out == t())
		{
			transpose_inline_same(index);
			return out;
		} else {
			transpose_inline_diff(index,outIndex,out);
			return out;
		}
	}

	//warning: index is already expected to be in the array format ( * 9 )
	@:extern inline private function transpose_inline_same(index:Int)
	{
		var tmp = this[index+1];
		this[index+1] = this[index+3];
		this[index+3] = tmp;

		tmp = this[index+2];
		this[index+2] = this[index+6];
		this[index+6] = tmp;

		tmp = this[index+5];
		this[index+5] = this[index+7];
		this[index+7] = tmp;
	}

	@:extern inline private function transpose_inline_diff(index:Int, outIndex:Int, out:Mat3Array)
	{
		out[outIndex+0] = this[index+0];
		out[outIndex+1] = this[index+3];
		out[outIndex+2] = this[index+6];
		out[outIndex+3] = this[index+1];
		out[outIndex+4] = this[index+4];
		out[outIndex+5] = this[index+7];
		out[outIndex+6] = this[index+2];
		out[outIndex+7] = this[index+5];
		out[outIndex+8] = this[index+8];
	}

	/**
		Inverts current matrix at `index` and stores the value at `outIndex` on `out` matrix array

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3Array`; If the operation fails, returns `null`
	 **/
	@:extern public inline function invert(index:Int, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return invert_impl(index, out, outIndex);
	}

	private function invert_impl(index:Int, out:Mat3Array, outIndex:Int):Mat3Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex * 9;
		index *= 9;

		return invert_inline(index,outIndex,out);
	}

	@:extern inline private function invert_inline(index:Int, outIndex:Int, out:Mat3Array):Mat3Array
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2],
				a10 = this[index+3], a11 = this[index+4], a12 = this[index+5],
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];

		var b01 = a22 * a11 - a12 * a21,
				b11 = -a22 * a10 + a12 * a20,
				b21 = a21 * a10 - a11 * a20;

		// Calculate the determinant
		var det = a00 * b01 + a01 * b11 + a02 * b21;
		if (det == 0)
		{
			return null;
		} else {
			det = 1 / det;

			out[outIndex+0] = b01 * det;
			out[outIndex+1] = (-a22 * a01 + a02 * a21) * det;
			out[outIndex+2] = (a12 * a01 - a02 * a11) * det;
			out[outIndex+3] = b11 * det;
			out[outIndex+4] = (a22 * a00 - a02 * a20) * det;
			out[outIndex+5] = (-a12 * a00 + a02 * a10) * det;
			out[outIndex+6] = b21 * det;
			out[outIndex+7] = (-a21 * a00 + a01 * a20) * det;
			out[outIndex+8] = (a11 * a00 - a01 * a10) * det;

			return out;
		}
	}

	/**
		Calculates the adjugate of a Mat3Array at `index`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3Array`;
	 **/
	@:extern public inline function adjoint(index:Int, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return adjoint_impl(index, out, outIndex);
	}

	private function adjoint_impl(index:Int, out:Mat3Array, outIndex:Int):Mat3Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex * 9;
		index *= 9;

		adjoint_inline(index,outIndex,out);
		return out;
	}

	@:extern inline private function adjoint_inline(index:Int, outIndex:Int, out:Mat3Array)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2],
				a10 = this[index+3], a11 = this[index+4], a12 = this[index+5],
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];

		out[outIndex+0] = (a11 * a22 - a12 * a21);
		out[outIndex+1] = (a02 * a21 - a01 * a22);
		out[outIndex+2] = (a01 * a12 - a02 * a11);
		out[outIndex+3] = (a12 * a20 - a10 * a22);
		out[outIndex+4] = (a00 * a22 - a02 * a20);
		out[outIndex+5] = (a02 * a10 - a00 * a12);
		out[outIndex+6] = (a10 * a21 - a11 * a20);
		out[outIndex+7] = (a01 * a20 - a00 * a21);
		out[outIndex+8] = (a00 * a11 - a01 * a10);
	}

	/**
		Calculates de determinant of the Mat3 at `index`
	 **/
	public function determinant(index:Int):Float
	{
		index *= 9;
		return determinant_inline(index);
	}

	@:extern inline private function determinant_inline(index:Int):Float
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2],
				a10 = this[index+3], a11 = this[index+4], a12 = this[index+5],
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];

		return a00 * (a22 * a11 - a12 * a21) + a01 * (-a22 * a10 + a12 * a20) + a02 * (a21 * a10 - a11 * a20);
	}

	/**
		Multiplies current matrix at `index` with matrix array `b` at `bIndex`,
		and stores the value at `outIndex` on `out` matrix array

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3Array`
	 **/
	@:extern public inline function mul(index:Int, b:Mat3Array, bIndex:Int, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return mul_impl(index, b, bIndex, out, outIndex);
	}

	private function mul_impl(index:Int, b:Mat3Array, bIndex:Int, out:Mat3Array, outIndex:Int):Mat3Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex * 9;
		index *= 9;
		bIndex *= 9;

		multiply_inline(index,b,bIndex,outIndex,out);
		return out;
	}

	@:extern inline private function multiply_inline(index:Int, b:Mat3Array, bIndex:Int, outIndex:Int, out:Mat3Array)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2],
				a10 = this[index+3], a11 = this[index+4], a12 = this[index+5],
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];
		var b00 = b[bIndex+0], b01 = b[bIndex+1], b02 = b[bIndex+2],
				b10 = b[bIndex+3], b11 = b[bIndex+4], b12 = b[bIndex+5],
				b20 = b[bIndex+6], b21 = b[bIndex+7], b22 = b[bIndex+8];

		out[outIndex+0] = b00 * a00 + b01 * a10 + b02 * a20;
		out[outIndex+1] = b00 * a01 + b01 * a11 + b02 * a21;
		out[outIndex+2] = b00 * a02 + b01 * a12 + b02 * a22;

		out[outIndex+3] = b10 * a00 + b11 * a10 + b12 * a20;
		out[outIndex+4] = b10 * a01 + b11 * a11 + b12 * a21;
		out[outIndex+5] = b10 * a02 + b11 * a12 + b12 * a22;

		out[outIndex+6] = b20 * a00 + b21 * a10 + b22 * a20;
		out[outIndex+7] = b20 * a01 + b21 * a11 + b22 * a21;
		out[outIndex+8] = b20 * a02 + b21 * a12 + b22 * a22;
	}

	/**
		Translates the mat4 at `index` with `x` and `y`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3Array`
	 **/
	@:extern public inline function translate(index:Int, x:Single, y:Single, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return translate_impl(index, x, y, out, outIndex);
	}

	private function translate_impl(index:Int, x:Single, y:Single, out:Mat3Array, outIndex:Int):Mat3Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		if (out == t() && outIndex == index)
		{
			index *= 9;
			//TODO double check / branch vs simpler check
			translate_inline_same(index,x,y);
		} else {
			index *= 9;
			// force outIndex to be Int, not Null<Int>
			outIndex = outIndex * 9;

			translate_inline_diff(index,x,y,out,outIndex);
		}

		return out;
	}

	@:extern inline private function translate_inline_same(index:Int, x:Single, y:Single)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2],
				a10 = this[index+3], a11 = this[index+4], a12 = this[index+5],
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];
		this[index+6] = x * a00 + y * a10 + a20;
		this[index+7] = x * a01 + y * a11 + a21;
		this[index+8] = x * a02 + y * a12 + a22;
	}

	@:extern inline private function translate_inline_diff(index:Int, x:Single, y:Single, out:Mat3Array, outIndex:Int)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2],
				a10 = this[index+3], a11 = this[index+4], a12 = this[index+5],
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];

		out[outIndex+0] = a00;
		out[outIndex+1] = a01;
		out[outIndex+2] = a02;

		out[outIndex+3] = a10;
		out[outIndex+4] = a11;
		out[outIndex+5] = a12;

		out[outIndex+6] = x * a00 + y * a10 + a20;
		out[outIndex+7] = x * a01 + y * a11 + a21;
		out[outIndex+8] = x * a02 + y * a12 + a22;
	}

	/**
		Translates the mat4 with the `vec` Vec2
		@see Mat3Array#translate
	 **/
	@:extern inline public function translatev(index:Int, vec:Vec2, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return translate(index,vec[0],vec[1],out,outIndex);
	}

	/**
		Scales the mat4 by `x`, `y`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3Array`
	 **/
	@:extern public inline function scale(index:Int, x:Single, y:Single, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return scale_impl(index, x, y, out, outIndex);
	}

	private function scale_impl(index:Int, x:Single, y:Single, out:Mat3Array, outIndex:Int):Mat3Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex * 9;
		index *= 9;

		scale_inline(index,x,y,out,outIndex);
		return out;
	}

	@:extern inline private function scale_inline(index:Int, x:Single, y:Single, out:Mat3Array, outIndex:Int)
	{
		var a00 = this[index+0] * x, a01 = this[index+1] * x, a02 = this[index+2] * x,
				a10 = this[index+3] * y, a11 = this[index+4] * y, a12 = this[index+5] * y,
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];
		//hope this to be optimized
		out[outIndex+0] = a00;
		out[outIndex+1] = a01;
		out[outIndex+2] = a02;
		out[outIndex+3] = a10;
		out[outIndex+4] = a11;
		out[outIndex+5] = a12;
		if (out != t() || index != outIndex)
		{
			out[outIndex+6] = a20;
			out[outIndex+7] = a21;
			out[outIndex+8] = a22;
		}
	}

	@:extern inline public function scalev(index:Int, vec:Vec2, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return scale(index,vec[0],vec[1],out,outIndex);
	}

	/**
		Rotates `this` matrix by the given angle at the (`x`, `y`) vector

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat3Array`
	 **/
	@:extern public inline function rotate(index:Int, angle:Rad, x:Single, y:Single, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return rotate_impl(index, angle, x, y, out, outIndex);
	}

	private function rotate_impl(index:Int, angle:Rad, x:Single, y:Single, out:Mat3Array, outIndex:Int):Mat3Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex * 9;
		index *= 9;

		rotate_inline(index,angle,x,y,out,outIndex);
		return out;
	}

	@:extern inline private function rotate_inline(index:Int, angle:Rad, x:Single, y:Single, out:Mat3Array, outIndex:Int)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2],
				a10 = this[index+3], a11 = this[index+4], a12 = this[index+5],
				a20 = this[index+6], a21 = this[index+7], a22 = this[index+8];
		var c = angle.cos(), s = angle.sin();
		var t = 1 - c;

		out[outIndex+0] = c * a00 + s * a10;
		out[outIndex+1] = c * a01 + s * a11;
		out[outIndex+2] = c * a02 + s * a12;

		out[outIndex+3] = c * a10 - s * a00;
		out[outIndex+4] = c * a11 - s * a01;
		out[outIndex+5] = c * a12 - s * a02;

		out[outIndex+6] = a20;
		out[outIndex+7] = a21;
		out[outIndex+8] = a22;
	}

	@:extern inline public function rotatev(index:Int, angle:Rad, vec:Vec2, ?out:Mat3Array, outIndex:Int=-1):Mat3Array
	{
		return rotate(index,angle,vec[0],vec[1],out,outIndex);
	}

	/**
		Copies the values from a Mat2D into a Mat3
	 **/
	public function fromMat2D(index:Int, b:Mat2DArray, bIndex:Int):Mat3Array
	{
		index *= 9; bIndex <<= 3;

		this[index+0] = b[bIndex+0];
		this[index+1] = b[bIndex+1];
		this[index+2] = 0;

		this[index+3] = b[bIndex+2];
		this[index+4] = b[bIndex+3];
		this[index+5] = 0;

		this[index+6] = b[bIndex+4];
		this[index+7] = b[bIndex+5];
		this[index+8] = 1;

		return t();
	}

	/**
		Copies the upper-left 3x3 values into the given mat3
	**/
	public function fromMat4(index:Int, b:Mat4Array, bIndex:Int):Mat3Array
	{
		index *= 9; bIndex <<= 4;
		this[index+0] = b[bIndex+0];
		this[index+1] = b[bIndex+1];
		this[index+2] = b[bIndex+2];
		this[index+3] = b[bIndex+4];
		this[index+4] = b[bIndex+5];
		this[index+5] = b[bIndex+6];
		this[index+6] = b[bIndex+8];
		this[index+7] = b[bIndex+9];
		this[index+8] = b[bIndex+10];

		return t();
	}

	/**
		Calculates a 4x4 matrix from the quaternion `quat` at `quatIndex`, and
		stores the result on `this` matrix as `index`

		Returns `this` matrix array
	 **/
	public function fromQuat(index:Int, quat:QuatArray, quatIndex:Int):Mat3Array
	{
		index *= 9;
		quatIndex <<= 2;
		fromQuat_inline(index,quat,quatIndex);
		return t();
	}

	@:extern inline private function fromQuat_inline(index:Int, q:QuatArray, quatIndex:Int)
	{
		var x = q[quatIndex+0], y = q[quatIndex+1], z = q[quatIndex+2], w = q[quatIndex+3];
		var x2 = x + x,
				y2 = y + y,
				z2 = z + z;

		var xx = x * x2,
				xy = x * y2,
				xz = x * z2,
				yy = y * y2,
				yz = y * z2,
				zz = z * z2,
				wx = w * x2,
				wy = w * y2,
				wz = w * z2;

		this[index+0] = 1 - (yy + zz);
		this[index+3] = xy + wz;
		this[index+6] = xz - wy;

		this[index+1] = xy - wz;
		this[index+4] = 1 - (xx + zz);
		this[index+7] = yz + wx;

		this[index+2] = xz + wy;
		this[index+5] = yz - wx;
		this[index+8] = 1 - (xx + yy);
	}

	/**
		Calculates a 3x3 normal matrix (transpose inverse) from the 4x4 matrix
	 **/
	public function normalFromMat4(index:Int, b:Mat4Array, bIndex:Int):Mat3Array
	{
		index *= 9; bIndex <<= 4;
		var a00 = b[bIndex+0], a01 = b[bIndex+1], a02 = b[bIndex+2], a03 = b[bIndex+3],
				a10 = b[bIndex+4], a11 = b[bIndex+5], a12 = b[bIndex+6], a13 = b[bIndex+7],
				a20 = b[bIndex+8], a21 = b[bIndex+9], a22 = b[bIndex+10], a23 = b[bIndex+11],
				a30 = b[bIndex+12], a31 = b[bIndex+13], a32 = b[bIndex+14], a33 = b[bIndex+15];

		var b00 = a00 * a11 - a01 * a10,
				b01 = a00 * a12 - a02 * a10,
				b02 = a00 * a13 - a03 * a10,
				b03 = a01 * a12 - a02 * a11,
				b04 = a01 * a13 - a03 * a11,
				b05 = a02 * a13 - a03 * a12,
				b06 = a20 * a31 - a21 * a30,
				b07 = a20 * a32 - a22 * a30,
				b08 = a20 * a33 - a23 * a30,
				b09 = a21 * a32 - a22 * a31,
				b10 = a21 * a33 - a23 * a31,
				b11 = a22 * a33 - a23 * a32;

		// Calculate the determinant
		var det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

		if (det == 0) {
			return null;
		}
		det = 1.0 / det;

		this[index+0] = (a11 * b11 - a12 * b10 + a13 * b09) * det;
		this[index+1] = (a12 * b08 - a10 * b11 - a13 * b07) * det;
		this[index+2] = (a10 * b10 - a11 * b08 + a13 * b06) * det;

		this[index+3] = (a02 * b10 - a01 * b11 - a03 * b09) * det;
		this[index+4] = (a00 * b11 - a02 * b08 + a03 * b07) * det;
		this[index+5] = (a01 * b08 - a00 * b10 - a03 * b06) * det;

		this[index+6] = (a31 * b05 - a32 * b04 + a33 * b03) * det;
		this[index+7] = (a32 * b02 - a30 * b05 - a33 * b01) * det;
		this[index+8] = (a30 * b04 - a31 * b02 + a33 * b00) * det;

		return t();
	}

	public function eq(index:Int, b:Mat3Array, bIndex:Int):Bool
	{
		index *= 9; bIndex *= 9;
		if (this == b.getData() && index == bIndex)
			return true;
		else if (this == null || b == null)
			return false;

		for(i in 0...9)
		{
			var v = this[index+i] - b[bIndex+i];
			if (v != 0 && (v < 0 && v < -FastMath.EPSILON) || (v > FastMath.EPSILON)) //this != b
				return false;
		}
		return true;
	}

	public function toString():String
	{
		var buf = new StringBuf();
		var len = Std.int(this.length / 9);
		if (len * 9 > this.length) len--; //be safe
		buf.add('mat3[');
		buf.add(len);
		buf.add(']\n{');
		var support = [], maxn = 0;
		for (i in 0...len)
		{
			buf.add('\n\t');
			buf.add('mat3(');
			for (j in 0...9)
			{
				var s = support[ j ] = this[ (i * 9) + j ] + "";
				if (s.length > maxn) maxn = s.length;
			}

			var fst = true;
			for (j in 0...3)
			{
				if (fst) fst = false; else buf.add('\n\t     ');
				for (k in 0...3)
				{
					buf.add(StringTools.rpad(support[ (j * 3) + k ], " ", maxn));
				}
			}
			buf.add("), ");
		}
		buf.add("\n}");

		return buf.toString();
	}

	@:arrayAccess inline private function getRaw(idx:Int):Single
	{
		return this[idx];
	}

	@:arrayAccess inline private function setRaw(idx:Int, v:Single):Single
	{
		return this[idx] = v;
	}
}

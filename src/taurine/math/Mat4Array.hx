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
	4x4 Matrix Array
 **/
abstract Mat4Array(SingleVector)
{
	/**
		Creates a new Mat4Array with the given size.
		All elements will be 0, and not identity matrices
	 **/
	@:extern public inline function new(len:Int)
	{
		this = SingleVector.alloc(len << 4);
	}

	/**
		The number of Mat4 elements contained in this array
	 **/
	public var length(get,never):Int;

	@:extern private inline function get_length():Int
	{
		return this.length >>> 4;
	}

	@:extern private inline function t():Mat4Array return untyped this; //get `this` as the abstract type

	/**
		Reinterpret `this` array as its first `Mat4`
	 **/
	@:extern inline public function first():Mat4
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Clones the matrix at `index`
	**/
	public function cloneAt(index:Int):Mat4
	{
		var out = Mat4.mk();
		index <<= 4;
		for (i in 0...16)
			out[i] = this[index+i];
		return out;
	}

	/**
		Creates a copy of the current Mat4Array and returns it
	 **/
	public function copy():Mat4Array
	{
		var len = this.length;
		var ret = new Mat4Array(len >>> 4);
		SingleVector.blit(this, 0, ret.getData(), 0, len);
		return ret;
	}

	/**
		Copies Mat4 at `index` to `out`, at `outIndex`
		Returns `out` object
	 **/
	public function copyTo(index:Int, out:Mat4Array, outIndex:Int)
	{
		index <<= 4; outIndex = outIndex << 4;
		for (i in 0...16)
			out[outIndex + i] = this[index + i];
		return out;
	}

	/**
		Set the Mat4 at `index` to the identity matrix.

		Returns itself
	 **/
	public function identity(index:Int):Mat4Array
	{
		index = index << 4;
		this[index] = this[index+5] = this[index+10] = this[index+15] = 1;
		this[index+1] = this[index+2] = this[index+3] = this[index+4] =
			this[index+6] = this[index+7] = this[index+8] = this[index+9] =
			this[index+11] = this[index+12] = this[index+13] = this[index+14] = 0;
		return t();
	}

	/**
		Transpose the values of a Mat4 at `index` and stores the result at `out` (at `outIndex`).

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function transpose(index:Int, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return transpose_impl(index, out, outIndex);
	}

	private function transpose_impl(index:Int, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		outIndex = outIndex << 4;
		index <<= 4;

		if (outIndex == index && out == t())
		{
			transpose_inline_same(index);
			return out;
		} else {
			transpose_inline_diff(index,outIndex,out);
			return out;
		}
	}

	//warning: index is already expected to be in the array format ( * 16 )
	@:extern inline private function transpose_inline_same(index:Int)
	{
		var tmp = this[index+1];
		this[index+1] = this[index+4];
		this[index+4] = tmp;

		tmp = this[index+2];
		this[index+2] = this[index+8];
		this[index+8] = tmp;

		tmp = this[index+3];
		this[index+3] = this[index+12];
		this[index+12] = tmp;

		tmp = this[index+6];
		this[index+6] = this[index+9];
		this[index+9] = tmp;

		tmp = this[index+7];
		this[index+7] = this[index+13];
		this[index+13] = tmp;

		tmp = this[index+11];
		this[index+11] = this[index+14];
		this[index+14] = tmp;
	}

	@:extern inline private function transpose_inline_diff(index:Int, outIndex:Int, out:Mat4Array)
	{
		out[outIndex+0] = this[index+0];
		out[outIndex+1] = this[index+4];
		out[outIndex+2] = this[index+8];
		out[outIndex+3] = this[index+12];
		out[outIndex+4] = this[index+1];
		out[outIndex+5] = this[index+5];
		out[outIndex+6] = this[index+9];
		out[outIndex+7] = this[index+13];
		out[outIndex+8] = this[index+2];
		out[outIndex+9] = this[index+6];
		out[outIndex+10] = this[index+10];
		out[outIndex+11] = this[index+14];
		out[outIndex+12] = this[index+3];
		out[outIndex+13] = this[index+7];
		out[outIndex+14] = this[index+11];
		out[outIndex+15] = this[index+15];
	}

	/**
		Inverts current matrix at `index` and stores the value at `outIndex` on `out` matrix array

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`; If the operation fails, returns `null`
	 **/
	@:extern public inline function invert(index:Int, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return invert_impl(index, out, outIndex);
	}

	private function invert_impl(index:Int, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;

		return invert_inline(index,outIndex,out);
	}

	@:extern inline private function invert_inline(index:Int, outIndex:Int, out:Mat4Array):Mat4Array
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2], a03 = this[index+3],
				a10 = this[index+4], a11 = this[index+5], a12 = this[index+6], a13 = this[index+7],
				a20 = this[index+8], a21 = this[index+9], a22 = this[index+10], a23 = this[index+11],
				a30 = this[index+12], a31 = this[index+13], a32 = this[index+14], a33 = this[index+15];

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
		if (det == 0)
		{
			return null;
		} else {
			det = 1 / det;

			out[outIndex+0] = (a11 * b11 - a12 * b10 + a13 * b09) * det;
			out[outIndex+1] = (a02 * b10 - a01 * b11 - a03 * b09) * det;
			out[outIndex+2] = (a31 * b05 - a32 * b04 + a33 * b03) * det;
			out[outIndex+3] = (a22 * b04 - a21 * b05 - a23 * b03) * det;
			out[outIndex+4] = (a12 * b08 - a10 * b11 - a13 * b07) * det;
			out[outIndex+5] = (a00 * b11 - a02 * b08 + a03 * b07) * det;
			out[outIndex+6] = (a32 * b02 - a30 * b05 - a33 * b01) * det;
			out[outIndex+7] = (a20 * b05 - a22 * b02 + a23 * b01) * det;
			out[outIndex+8] = (a10 * b10 - a11 * b08 + a13 * b06) * det;
			out[outIndex+9] = (a01 * b08 - a00 * b10 - a03 * b06) * det;
			out[outIndex+10] = (a30 * b04 - a31 * b02 + a33 * b00) * det;
			out[outIndex+11] = (a21 * b02 - a20 * b04 - a23 * b00) * det;
			out[outIndex+12] = (a11 * b07 - a10 * b09 - a12 * b06) * det;
			out[outIndex+13] = (a00 * b09 - a01 * b07 + a02 * b06) * det;
			out[outIndex+14] = (a31 * b01 - a30 * b03 - a32 * b00) * det;
			out[outIndex+15] = (a20 * b03 - a21 * b01 + a22 * b00) * det;

			return out;
		}
	}

	/**
		Calculates the adjugate of a Mat4Array at `index`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`;
	 **/
	@:extern public inline function adjoint(index:Int, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return adjoint_impl(index, out, outIndex);
	}

	private function adjoint_impl(index:Int, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;

		adjoint_inline(index,outIndex,out);
		return out;
	}

	@:extern inline private function adjoint_inline(index:Int, outIndex:Int, out:Mat4Array)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2], a03 = this[index+3],
				a10 = this[index+4], a11 = this[index+5], a12 = this[index+6], a13 = this[index+7],
				a20 = this[index+8], a21 = this[index+9], a22 = this[index+10], a23 = this[index+11],
				a30 = this[index+12], a31 = this[index+13], a32 = this[index+14], a33 = this[index+15];

		out[outIndex+0]  =  (a11 * (a22 * a33 - a23 * a32) - a21 * (a12 * a33 - a13 * a32) + a31 * (a12 * a23 - a13 * a22));
		out[outIndex+1]  = -(a01 * (a22 * a33 - a23 * a32) - a21 * (a02 * a33 - a03 * a32) + a31 * (a02 * a23 - a03 * a22));
		out[outIndex+2]  =  (a01 * (a12 * a33 - a13 * a32) - a11 * (a02 * a33 - a03 * a32) + a31 * (a02 * a13 - a03 * a12));
		out[outIndex+3]  = -(a01 * (a12 * a23 - a13 * a22) - a11 * (a02 * a23 - a03 * a22) + a21 * (a02 * a13 - a03 * a12));
		out[outIndex+4]  = -(a10 * (a22 * a33 - a23 * a32) - a20 * (a12 * a33 - a13 * a32) + a30 * (a12 * a23 - a13 * a22));
		out[outIndex+5]  =  (a00 * (a22 * a33 - a23 * a32) - a20 * (a02 * a33 - a03 * a32) + a30 * (a02 * a23 - a03 * a22));
		out[outIndex+6]  = -(a00 * (a12 * a33 - a13 * a32) - a10 * (a02 * a33 - a03 * a32) + a30 * (a02 * a13 - a03 * a12));
		out[outIndex+7]  =  (a00 * (a12 * a23 - a13 * a22) - a10 * (a02 * a23 - a03 * a22) + a20 * (a02 * a13 - a03 * a12));
		out[outIndex+8]  =  (a10 * (a21 * a33 - a23 * a31) - a20 * (a11 * a33 - a13 * a31) + a30 * (a11 * a23 - a13 * a21));
		out[outIndex+9]  = -(a00 * (a21 * a33 - a23 * a31) - a20 * (a01 * a33 - a03 * a31) + a30 * (a01 * a23 - a03 * a21));
		out[outIndex+10] =  (a00 * (a11 * a33 - a13 * a31) - a10 * (a01 * a33 - a03 * a31) + a30 * (a01 * a13 - a03 * a11));
		out[outIndex+11] = -(a00 * (a11 * a23 - a13 * a21) - a10 * (a01 * a23 - a03 * a21) + a20 * (a01 * a13 - a03 * a11));
		out[outIndex+12] = -(a10 * (a21 * a32 - a22 * a31) - a20 * (a11 * a32 - a12 * a31) + a30 * (a11 * a22 - a12 * a21));
		out[outIndex+13] =  (a00 * (a21 * a32 - a22 * a31) - a20 * (a01 * a32 - a02 * a31) + a30 * (a01 * a22 - a02 * a21));
		out[outIndex+14] = -(a00 * (a11 * a32 - a12 * a31) - a10 * (a01 * a32 - a02 * a31) + a30 * (a01 * a12 - a02 * a11));
		out[outIndex+15] =  (a00 * (a11 * a22 - a12 * a21) - a10 * (a01 * a22 - a02 * a21) + a20 * (a01 * a12 - a02 * a11));
		return out;
	}

	/**
		Calculates de determinant of the Mat4 at `index`
	 **/
	public function det(index:Int):Float
	{
		index <<= 4;
		return determinant_inline(index);
	}

	@:extern inline private function determinant_inline(index:Int):Float
	{
		var a00 = this[index], a01 = this[index+1], a02 = this[index+2], a03 = this[index+3],
				a10 = this[index+4], a11 = this[index+5], a12 = this[index+6], a13 = this[index+7],
				a20 = this[index+8], a21 = this[index+9], a22 = this[index+10], a23 = this[index+11],
				a30 = this[index+12], a31 = this[index+13], a32 = this[index+14], a33 = this[index+15];

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
		return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
	}

	/**
		Multiplies current matrix at `index` with matrix array `b` at `bIndex`,
		and stores the value at `outIndex` on `out` matrix array

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function mul(index:Int, b:Mat4Array, bIndex:Int, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return mul_impl(index, b, bIndex, out, outIndex);
	}

	private function mul_impl(index:Int, b:Mat4Array, bIndex:Int, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;
		bIndex <<= 4;

		multiply_inline(index,b,bIndex,outIndex,out);
		return out;
	}

	@:extern inline private function multiply_inline(index:Int, b:Mat4Array, bIndex:Int, outIndex:Int, out:Mat4Array)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2], a03 = this[index+3],
				a10 = this[index+4], a11 = this[index+5], a12 = this[index+6], a13 = this[index+7],
				a20 = this[index+8], a21 = this[index+9], a22 = this[index+10], a23 = this[index+11],
				a30 = this[index+12], a31 = this[index+13], a32 = this[index+14], a33 = this[index+15];
		var b0 = b[bIndex+0], b1 = b[bIndex+1], b2 = b[bIndex+2], b3 = b[bIndex+3],
				b4 = b[bIndex+4], b5 = b[bIndex+5], b6 = b[bIndex+6], b7 = b[bIndex+7],
				b8 = b[bIndex+8], b9 = b[bIndex+9], b10 = b[bIndex+10], b11 = b[bIndex+11],
				b12 = b[bIndex+12], b13 = b[bIndex+13], b14 = b[bIndex+14], b15 = b[bIndex+15];

		out[outIndex+0] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
		out[outIndex+1] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
		out[outIndex+2] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
		out[outIndex+3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

		out[outIndex+4] = b4*a00 + b5*a10 + b6*a20 + b7*a30;
		out[outIndex+5] = b4*a01 + b5*a11 + b6*a21 + b7*a31;
		out[outIndex+6] = b4*a02 + b5*a12 + b6*a22 + b7*a32;
		out[outIndex+7] = b4*a03 + b5*a13 + b6*a23 + b7*a33;

		out[outIndex+8] = b8*a00 + b9*a10 + b10*a20 + b11*a30;
		out[outIndex+9] = b8*a01 + b9*a11 + b10*a21 + b11*a31;
		out[outIndex+10] = b8*a02 + b9*a12 + b10*a22 + b11*a32;
		out[outIndex+11] = b8*a03 + b9*a13 + b10*a23 + b11*a33;

		out[outIndex+12] = b12*a00 + b13*a10 + b14*a20 + b15*a30;
		out[outIndex+13] = b12*a01 + b13*a11 + b14*a21 + b15*a31;
		out[outIndex+14] = b12*a02 + b13*a12 + b14*a22 + b15*a32;
		out[outIndex+15] = b12*a03 + b13*a13 + b14*a23 + b15*a33;
	}

	/**
		Translates the mat4 at `index` with `x`, `y` and `z`.

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function translate(index:Int, x:Single, y:Single, z:Single, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return translate_impl(index, x, y, z, out, outIndex);
	}

	private function translate_impl(index:Int, x:Single, y:Single, z:Single, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		index <<= 4;
		if (out == t() && outIndex == index)
		{
			//TODO double check / branch vs simpler check
			translate_inline_same(index,x,y,z);
		} else {
			// force outIndex to be Int, not Null<Int>
			outIndex = outIndex << 4;

			translate_inline_diff(index,x,y,z,out,outIndex);
		}
		return out;
	}

	@:extern inline private function translate_inline_same(index:Int, x:Single, y:Single, z:Single)
	{
		var i12 = this[index+0] * x + this[index+4] * y + this[index+8] * z + this[index+12],
				i13 = this[index+1] * x + this[index+5] * y + this[index+9] * z + this[index+13],
				i14 = this[index+2] * x + this[index+6] * y + this[index+10] * z + this[index+14],
				i15 = this[index+3] * x + this[index+7] * y + this[index+11] * z + this[index+15];
		this[index+12] = i12;
		this[index+13] = i13;
		this[index+14] = i14;
		this[index+15] = i15;
	}

	@:extern inline private function translate_inline_diff(index:Int, x:Single, y:Single, z:Single, out:Mat4Array, outIndex:Int)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2], a03 = this[index+3],
				a10 = this[index+4], a11 = this[index+5], a12 = this[index+6], a13 = this[index+7],
				a20 = this[index+8], a21 = this[index+9], a22 = this[index+10], a23 = this[index+11],
				a30 = this[index+12], a31 = this[index+13], a32 = this[index+14], a33 = this[index+15];

		out[outIndex+0] = a00; out[outIndex+1] = a01; out[outIndex+2] = a02; out[outIndex+3] = a03;
		out[outIndex+4] = a10; out[outIndex+5] = a11; out[outIndex+6] = a12; out[outIndex+7] = a13;
		out[outIndex+8] = a20; out[outIndex+9] = a21; out[outIndex+10] = a22; out[outIndex+11] = a23;

		out[outIndex+12] = a00 * x + a10 * y + a20 * z + a30;
		out[outIndex+13] = a01 * x + a11 * y + a21 * z + a31;
		out[outIndex+14] = a02 * x + a12 * y + a22 * z + a32;
		out[outIndex+15] = a03 * x + a13 * y + a23 * z + a33;
	}

	/**
		Translates the mat4 with the `vec` Vec3
		@see Mat4Array#translate
	 **/
	@:extern inline public function translatev(index:Int, vec:Vec3, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return translate(index,vec[0],vec[1],vec[2],out,outIndex);
	}

	/**
		Scales the mat4 by `x`, `y`, `z`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function scale(index:Int, x:Single, y:Single, z:Single, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return scale_impl(index, x, y, z, out, outIndex);
	}

	private function scale_impl(index:Int, x:Single, y:Single, z:Single, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;

		scale_inline(index,x,y,z,out,outIndex);
		return out;
	}

	@:extern inline private function scale_inline(index:Int, x:Single, y:Single, z:Single, out:Mat4Array, outIndex:Int)
	{
		var a00 = this[index+0] * x, a01 = this[index+1] * x, a02 = this[index+2] * x, a03 = this[index+3] * x,
				a10 = this[index+4] * y, a11 = this[index+5] * y, a12 = this[index+6] * y, a13 = this[index+7] * y,
				a20 = this[index+8] * z, a21 = this[index+9] * z, a22 = this[index+10] * z, a23 = this[index+11] * z,
				a30 = this[index+12], a31 = this[index+13], a32 = this[index+14], a33 = this[index+15];
		//hope this to be optimized
		out[outIndex+0] = a00;
		out[outIndex+1] = a01;
		out[outIndex+2] = a02;
		out[outIndex+3] = a03;
		out[outIndex+4] = a10;
		out[outIndex+5] = a11;
		out[outIndex+6] = a12;
		out[outIndex+7] = a13;
		out[outIndex+8] = a20;
		out[outIndex+9] = a21;
		out[outIndex+10] = a22;
		out[outIndex+11] = a23;
		if (out != t() || index != outIndex)
		{
			out[outIndex+12] = a30;
			out[outIndex+13] = a31;
			out[outIndex+14] = a32;
			out[outIndex+15] = a33;
		}
	}

	@:extern inline public function scalev(index:Int, vec:Vec3, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return scale(index,vec[0],vec[1],vec[2],out,outIndex);
	}

	/**
		Rotates `this` matrix by the given angle at the (`x`, `y`, `z`) vector

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function rotate(index:Int, angle:Rad, x:Single, y:Single, z:Single, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return rotate_impl(index, angle, x, y, z, out, outIndex);
	}

	private function rotate_impl(index:Int, angle:Rad, x:Single, y:Single, z:Single, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;

		rotate_inline(index,angle,x,y,z,out,outIndex);
		return out;
	}

	@:extern inline private function rotate_inline(index:Int, angle:Rad, x:Single, y:Single, z:Single, out:Mat4Array, outIndex:Int)
	{
		var a00 = this[index+0], a01 = this[index+1], a02 = this[index+2], a03 = this[index+3],
				a10 = this[index+4], a11 = this[index+5], a12 = this[index+6], a13 = this[index+7],
				a20 = this[index+8], a21 = this[index+9], a22 = this[index+10], a23 = this[index+11];
		var c = angle.cos(), s = angle.sin();
		var t = 1 - c;

		var len = FastMath.invsqrt(x*x + y*y + z*z);
		x *= len; y *= len; z *= len;

		// Construct the elements of the rotation matrix
		var b00 = x * x * t + c, b01 = y * x * t + z * s, b02 = z * x * t - y * s,
				b10 = x * y * t - z * s, b11 = y * y * t + c, b12 = z * y * t + x * s,
				b20 = x * z * t + y * s, b21 = y * z * t - x * s, b22 = z * z * t + c;

		// Perform rotation-specific matrix multiplication
		out[outIndex+0] = a00 * b00 + a10 * b01 + a20 * b02;
		out[outIndex+1] = a01 * b00 + a11 * b01 + a21 * b02;
		out[outIndex+2] = a02 * b00 + a12 * b01 + a22 * b02;
		out[outIndex+3] = a03 * b00 + a13 * b01 + a23 * b02;
		out[outIndex+4] = a00 * b10 + a10 * b11 + a20 * b12;
		out[outIndex+5] = a01 * b10 + a11 * b11 + a21 * b12;
		out[outIndex+6] = a02 * b10 + a12 * b11 + a22 * b12;
		out[outIndex+7] = a03 * b10 + a13 * b11 + a23 * b12;
		out[outIndex+8] = a00 * b20 + a10 * b21 + a20 * b22;
		out[outIndex+9] = a01 * b20 + a11 * b21 + a21 * b22;
		out[outIndex+10] = a02 * b20 + a12 * b21 + a22 * b22;
		out[outIndex+11] = a03 * b20 + a13 * b21 + a23 * b22;

		if ( (untyped this) != out || index != outIndex) { // If the source and destination differ, copy the unchanged last row
			out[outIndex+12] = this[index+12];
			out[outIndex+13] = this[index+13];
			out[outIndex+14] = this[index+14];
			out[outIndex+15] = this[index+15];
		}
	}

	@:extern inline public function rotatev(index:Int, angle:Rad, vec:Vec3, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return rotate(index,angle,vec[0],vec[1],vec[2],out,outIndex);
	}

	/**
		Rotates `this` matrix by the given angle at the X axis

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function rotateX(index:Int, angle:Rad, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return rotateX_impl(index, angle, out, outIndex);
	}

	private function rotateX_impl(index:Int, angle:Rad, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;

		rotateX_inline(index,angle,out,outIndex);

		return out;
	}

	@:extern inline private function rotateX_inline(index:Int, angle:Rad, out:Mat4Array, outIndex:Int)
	{
		var s = angle.sin(), c = angle.cos(),
				a10 = this[index+4],
				a11 = this[index+5],
				a12 = this[index+6],
				a13 = this[index+7],
				a20 = this[index+8],
				a21 = this[index+9],
				a22 = this[index+10],
				a23 = this[index+11];

		if (t() != out || index != outIndex) { // If the source and destination differ, copy the unchanged rows
			out[outIndex+0]  = this[index+0];
			out[outIndex+1]  = this[index+1];
			out[outIndex+2]  = this[index+2];
			out[outIndex+3]  = this[index+3];
			out[outIndex+12] = this[index+12];
			out[outIndex+13] = this[index+13];
			out[outIndex+14] = this[index+14];
			out[outIndex+15] = this[index+15];
		}

		// Perform axis-specific matrix multiplication
		out[outIndex+4] = a10 * c + a20 * s;
		out[outIndex+5] = a11 * c + a21 * s;
		out[outIndex+6] = a12 * c + a22 * s;
		out[outIndex+7] = a13 * c + a23 * s;
		out[outIndex+8] = a20 * c - a10 * s;
		out[outIndex+9] = a21 * c - a11 * s;
		out[outIndex+10] = a22 * c - a12 * s;
		out[outIndex+11] = a23 * c - a13 * s;
	}

	/**
		Rotates `this` matrix by the given angle at the Y axis

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function rotateY(index:Int, angle:Rad, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return rotateY_impl(index, angle, out, outIndex);
	}

	private function rotateY_impl(index:Int, angle:Rad, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;

		rotateY_inline(index,angle,out,outIndex);

		return out;
	}

	@:extern inline private function rotateY_inline(index:Int, angle:Rad, out:Mat4Array, outIndex:Int)
	{
		var s = angle.sin(), c = angle.cos(),
				a00 = this[index+0],
				a01 = this[index+1],
				a02 = this[index+2],
				a03 = this[index+3],
				a20 = this[index+8],
				a21 = this[index+9],
				a22 = this[index+10],
				a23 = this[index+11];

		if (t() != out || index != outIndex) { // If the source and destination differ, copy the unchanged rows
			out[outIndex+4]  = this[index+4];
			out[outIndex+5]  = this[index+5];
			out[outIndex+6]  = this[index+6];
			out[outIndex+7]  = this[index+7];
			out[outIndex+12] = this[index+12];
			out[outIndex+13] = this[index+13];
			out[outIndex+14] = this[index+14];
			out[outIndex+15] = this[index+15];
		}

		// Perform axis-specific matrix multiplication
		out[outIndex+0] = a00 * c - a20 * s;
		out[outIndex+1] = a01 * c - a21 * s;
		out[outIndex+2] = a02 * c - a22 * s;
		out[outIndex+3] = a03 * c - a23 * s;
		out[outIndex+8] = a00 * s + a20 * c;
		out[outIndex+9] = a01 * s + a21 * c;
		out[outIndex+10] = a02 * s + a22 * c;
		out[outIndex+11] = a03 * s + a23 * c;
	}

	/**
		Rotates `this` matrix by the given angle at the Z axis

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4Array`
	 **/
	@:extern public inline function rotateZ(index:Int, angle:Rad, ?out:Mat4Array, outIndex:Int=-1):Mat4Array
	{
		return rotateZ_impl(index, angle, out, outIndex);
	}

	private function rotateZ_impl(index:Int, angle:Rad, out:Mat4Array, outIndex:Int):Mat4Array
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 4;
		index <<= 4;

		rotateZ_inline(index,angle,out,outIndex);

		return out;
	}

	@:extern inline private function rotateZ_inline(index:Int, angle:Rad, out:Mat4Array, outIndex:Int)
	{
		var s = angle.sin(), c = angle.cos(),
				a00 = this[index+0],
				a01 = this[index+1],
				a02 = this[index+2],
				a03 = this[index+3],
				a10 = this[index+4],
				a11 = this[index+5],
				a12 = this[index+6],
				a13 = this[index+7];

		// Perform axis-specific matrix multiplication
		out[outIndex+0] = a00 * c + a10 * s;
		out[outIndex+1] = a01 * c + a11 * s;
		out[outIndex+2] = a02 * c + a12 * s;
		out[outIndex+3] = a03 * c + a13 * s;
		out[outIndex+4] = a10 * c - a00 * s;
		out[outIndex+5] = a11 * c - a01 * s;
		out[outIndex+6] = a12 * c - a02 * s;
		out[outIndex+7] = a13 * c - a03 * s;

		if (t() != out || index != outIndex) { // If the source and destination differ, copy the unchanged rows
			out[outIndex+8]  = this[index+8];
			out[outIndex+9]  = this[index+9];
			out[outIndex+10] = this[index+10];
			out[outIndex+11] = this[index+11];
			out[outIndex+12] = this[index+12];
			out[outIndex+13] = this[index+13];
			out[outIndex+14] = this[index+14];
			out[outIndex+15] = this[index+15];
		}
	}

	/**
		Calculates the matrix from the quaternion `quat` at `quatIndex`, and
		translation at `x`, `y` and `z`, and stores it on `this` matix at `index`

		Returns `this` matrix array
	 **/
	public function fromQuatPos(index:Int, quat:QuatArray, quatIndex:Int, x:Single, y:Single, z:Single):Mat4Array
	{
		index <<= 4;
		quatIndex <<= 2;
		fromQuatPos_inline(index,quat,quatIndex,x,y,z);
		return t();
	}

	@:extern inline private function fromQuatPos_inline(index:Int, q:QuatArray, quatIndex:Int, x:Single, y:Single, z:Single)
	{
		// Quaternion math
		var x = q[quatIndex+0], y = q[quatIndex+1], z = q[quatIndex+2], w = q[quatIndex+3],
				x2 = x + x,
				y2 = y + y,
				z2 = z + z,

				xx = x * x2,
				xy = x * y2,
				xz = x * z2,
				yy = y * y2,
				yz = y * z2,
				zz = z * z2,
				wx = w * x2,
				wy = w * y2,
				wz = w * z2;

		this[index+0] = 1 - (yy + zz);
		this[index+1] = xy + wz;
		this[index+2] = xz - wy;
		this[index+3] = 0;
		this[index+4] = xy - wz;
		this[index+5] = 1 - (xx + zz);
		this[index+6] = yz + wx;
		this[index+7] = 0;
		this[index+8] = xz + wy;
		this[index+9] = yz - wx;
		this[index+10] = 1 - (xx + yy);
		this[index+11] = 0;
		this[index+12] = x;
		this[index+13] = y;
		this[index+14] = z;
		this[index+15] = 1;
	}

	/**
		@see fromQuatPos
	 **/
	@:extern inline public function fromQuatPos_v(index:Int, quat:QuatArray, quatIndex:Int, vec:Vec3):Mat4Array
	{
		return fromQuatPos(index,quat,quatIndex,vec[0],vec[1],vec[2]);
	}

	/**
		Calculates a 4x4 matrix from the quaternion `quat` at `quatIndex`, and
		stores the result on `this` matrix as `index`

		Returns `this` matrix array
	 **/
	public function fromQuat(index:Int, quat:QuatArray, quatIndex:Int):Mat4Array
	{
		index <<= 4;
		quatIndex <<= 2;
		fromQuat_inline(index,quat,quatIndex);
		return t();
	}

	@:extern inline private function fromQuat_inline(index:Int, q:QuatArray, quatIndex:Int)
	{
		// Quaternion math
		var x = q[quatIndex+0], y = q[quatIndex+1], z = q[quatIndex+2], w = q[quatIndex+3],
				x2 = x + x,
				y2 = y + y,
				z2 = z + z,

				xx = x * x2,
				xy = x * y2,
				xz = x * z2,
				yy = y * y2,
				yz = y * z2,
				zz = z * z2,
				wx = w * x2,
				wy = w * y2,
				wz = w * z2;

		this[index+0] = 1 - (yy + zz);
		this[index+1] = xy + wz;
		this[index+2] = xz - wy;
		this[index+3] = 0;
		this[index+4] = xy - wz;
		this[index+5] = 1 - (xx + zz);
		this[index+6] = yz + wx;
		this[index+7] = 0;
		this[index+8] = xz + wy;
		this[index+9] = yz - wx;
		this[index+10] = 1 - (xx + yy);
		this[index+11] = this[index+12] = this[index+13] = this[index+14] = 0;
		this[index+15] = 1;
	}

	/**
		Generates a frustum matrix with the given bounds and writes on `this` array, at `index`
	 **/
	public function frustum(index:Int, left:Single, right:Single, bottom:Single, top:Single, near:Single, far:Single):Mat4Array
	{
		index <<= 4;
		frustum_inline(index,left,right,bottom,top,near,far);
		return t();
	}

	@:extern inline private function frustum_inline(index:Int, left:Single, right:Single, bottom:Single, top:Single, near:Single, far:Single)
	{
		var rl = 1 / (right - left),
				tb = 1 / (top - bottom),
				nf = 1 / (near - far);
		this[index+0] = (near * 2) * rl;
		this[index+1] = 0;
		this[index+2] = 0;
		this[index+3] = 0;
		this[index+4] = 0;
		this[index+5] = (near * 2) * tb;
		this[index+6] = 0;
		this[index+7] = 0;
		this[index+8] = (right + left) * rl;
		this[index+9] = (top + bottom) * tb;
		this[index+10] = (far + near) * nf;
		this[index+11] = -1;
		this[index+12] = 0;
		this[index+13] = 0;
		this[index+14] = (far * near * 2) * nf;
		this[index+15] = 0;
	}

	/**
		Generates a perspective projection matrix with the given bounds and writes on `this` array, at `index`

		`fovy` - Vertical field of view in radians
		`aspect` - Aspect ratio, typically viewport width / height
		`near` - Near bound of the frustum
		`far` - Far bound of the frustum
	 **/
	public function perspective(index:Int, fovy:Rad, aspect:Single, near:Single, far:Single):Mat4Array
	{
		index <<= 4;
		perspective_inline(index,fovy,aspect,near,far);

		return t();
	}

	@:extern inline public function persp(index:Int, fovy:Rad, aspect:Single, near:Single, far:Single):Mat4Array
	{
		return perspective(index,fovy,aspect,near,far);
	}

	@:extern inline private function perspective_inline(index:Int, fovy:Rad, aspect:Single, near:Single, far:Single)
	{
		var f = 1.0 / Math.tan(fovy.float() / 2),
				nf = 1 / (near - far);
		this[index+0] = f / aspect;
		this[index+1] = this[index+2] = this[index+3] = this[index+4] = 0;
		this[index+5] = f;
		this[index+6] = this[index+7] = this[index+8] = this[index+9] = 0;
		this[index+10] = (far + near) * nf;
		this[index+11] = -1;
		this[index+12] = this[index+13] = 0;
		this[index+14] = (2 * far * near) * nf;
		this[index+15] = 0;
	}

	/**
		Generates an orthogonal matrix with the given bounds and writes on `this` mat array, at `index`
	 **/
	public function ortho(index:Int, left:Single, right:Single, bottom:Single, top:Single, near:Single, far:Single):Mat4Array
	{
		index <<=4;
		ortho_inline(index,left,right,bottom,top,near,far);
		return t();
	}

	@:extern inline private function ortho_inline(index:Int, left:Single, right:Single, bottom:Single, top:Single, near:Single, far:Single)
	{
		var lr = 1 / (left - right),
				bt = 1 / (bottom - top),
				nf = 1 / (near - far);
		this[index+0] = -2 * lr;
		this[index+1] = this[index+2] = this[index+3] = this[index+4] = 0;
		this[index+5] = -2 * bt;
		this[index+6] = this[index+7] = this[index+8] = this[index+9] = 0;
		this[index+10] = 2 * nf;
		this[index+11] = 0;
		this[index+12] = (left + right) * lr;
		this[index+13] = (top + bottom) * bt;
		this[index+14] = (far + near) * nf;
		this[index+15] = 1;
	}

	/**
		Generates a look-at matrix at `index`, with the given `eye` position,
		focal point(`center` at `centerIndex`), and `up` axis (at `upIndex`)
		`eye` - The position of the eye point (camera origin)
		`center` - The point to aim the camera at
		`up` - the vector that identifies the up direction for the camera

		Returns `this` Mat4Array
	 **/
	public function lookAt(index:Int, eye:Vec3Array, eyeIndex:Int, center:Vec3Array, centerIndex:Int, up:Vec3):Mat4Array
	{
		index <<= 4;
		eyeIndex = eyeIndex << 2;
		centerIndex = centerIndex << 2;

		lookAt_inline(index, eye, eyeIndex, center, centerIndex, up);
		return t();
	}

	@:extern inline private function lookAt_inline(index:Int, eye:Vec3Array, eyeIndex:Int, center:Vec3Array, centerIndex:Int, up:Vec3)
	{
		var eyex = eye[eyeIndex],
				eyey = eye[eyeIndex+1],
				eyez = eye[eyeIndex+2],
				upx = up[0],
				upy = up[1],
				upz = up[2],
				centerx = center[centerIndex],
				centery = center[centerIndex+1],
				centerz = center[centerIndex+2];

		if (FastMath.abs(eyex - centerx) < FastMath.EPSILON &&
				FastMath.abs(eyey - centery) < FastMath.EPSILON &&
				FastMath.abs(eyez - centerz) < FastMath.EPSILON)
		{
			identity(index);
		} else {
			var x0, x1, x2, y0, y1, y2, z0, z1, z2, len;
			z0 = eyex - centerx;
			z1 = eyey - centery;
			z2 = eyez - centerz;

			len = FastMath.invsqrt(z0 * z0 + z1 * z1 + z2 * z2);
			z0 *= len;
			z1 *= len;
			z2 *= len;

			x0 = upy * z2 - upz * z1;
			x1 = upz * z0 - upx * z2;
			x2 = upx * z1 - upy * z0;
			len = FastMath.sqrt(x0 * x0 + x1 * x1 + x2 * x2);
			if (len == 0) {
				x0 = 0;
				x1 = 0;
				x2 = 0;
			} else {
				len = 1 / len;
				x0 *= len;
				x1 *= len;
				x2 *= len;
			}

			y0 = z1 * x2 - z2 * x1;
			y1 = z2 * x0 - z0 * x2;
			y2 = z0 * x1 - z1 * x0;

			len = FastMath.sqrt(y0 * y0 + y1 * y1 + y2 * y2);
			if (len == 0) {
				y0 = 0;
				y1 = 0;
				y2 = 0;
			} else {
				len = 1 / len;
				y0 *= len;
				y1 *= len;
				y2 *= len;
			}

			this[index+0] = x0;
			this[index+1] = y0;
			this[index+2] = z0;
			this[index+3] = 0;
			this[index+4] = x1;
			this[index+5] = y1;
			this[index+6] = z1;
			this[index+7] = 0;
			this[index+8] = x2;
			this[index+9] = y2;
			this[index+10] = z2;
			this[index+11] = 0;
			this[index+12] = -(x0 * eyex + x1 * eyey + x2 * eyez);
			this[index+13] = -(y0 * eyex + y1 * eyey + y2 * eyez);
			this[index+14] = -(z0 * eyex + z1 * eyey + z2 * eyez);
			this[index+15] = 1;
		}
	}

	/**
		@see lookAt
	 **/
	@:extern inline public function lookAtv(index:Int, eye:Vec3, center:Vec3, up:Vec3):Mat4Array
	{
		return lookAt(index,eye,0,center,0,up);
	}

	/**
		Returns the `nth` val of `this` Matrix at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function val(index:Int, nth:Int):Single
	{
		return this[(index << 4) + nth];
	}

	/**
		Sets the `nth` val of `this` Matrix at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function setVal(index:Int, nth:Int, v:Single):Single
	{
		return this[(index << 4) + nth] = v;
	}

	/**
		Returns the value of `this` Matrix at `index`, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function matval(index:Int, row:Int, column:Int):Single
	{
		return this[(index << 4) + ( (row << 2) + column)];
	}

	/**
		Sets the value of `this` Matrix at `index`, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function setMatval(index:Int, row:Int, column:Int, v:Single):Single
	{
		return this[ (index << 4) + ( (row << 2) + column)] = v;
	}

	public function eq(index:Int, b:Mat4Array, bIndex:Int):Bool
	{
		index <<= 4; bIndex <<= 4;
		if (this == b.getData() && index == bIndex)
			return true;
		else if (this == null || b == null)
			return false;

		for(i in 0...16)
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
		var len = this.length >>> 4;
		if (len << 4 > this.length) len--; //be safe
		buf.add('mat4[');
		buf.add(len);
		buf.add(']\n{');
		var support = [], maxn = 0;
		for (i in 0...len)
		{
			buf.add('\n\t');
			buf.add('mat4(');
			for (j in 0...16)
			{
				var s = support[ j ] = this[ (i << 4) + j ] + "";
				if (s.length > maxn) maxn = s.length;
			}

			var fst = true;
			for (j in 0...4)
			{
				if (fst) fst = false; else buf.add('\n\t     ');
				for (k in 0...4)
				{
					buf.add(StringTools.rpad(support[ (j << 2) + k ], " ", maxn));
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

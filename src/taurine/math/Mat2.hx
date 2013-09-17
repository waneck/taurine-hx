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
	2 x 2 Matrix
**/
@:arrayAccess
abstract Mat2(Vector<Single>)
{

	/**
		Creates a new indentity Mat2
	**/
	public inline function new()
	{
		this = VectorTools.create(4);
		this[0] = this[3] = 1;
#if !static
		this[1] = this[2] = 0;
#end
	}

	public static inline function mk():Mat2
	{
		return untyped (VectorTools.create(4) : Vector<Single>);
	}

	private inline function t():Mat2 return untyped this; //get `this` as the abstract type

	/**
		Copy the value from one mat2 to another. If no matrix is entered, a new matrix is returned
	**/
	public function copy(?out:Mat2):Mat2
	{
		if (out == null) out = mkmat();
		out[0] = this[0];
		out[1] = this[1];
		out[2] = this[2];
		out[3] = this[3];
		return out;
	}

	/**
		Set a mat2 to the identity matrix

		Returns itself
	**/
	public function identity():Mat2
	{
		this[0] = this[3] = 1;
		this[1] = this[2] = 0;

		return untyped this;
	}

	/**
		Transpose the values of a `Mat2` to `out`. If no `out` parameter is entered, the matrix will transpose itself
	**/
	public function transpose(?out:Mat2):Mat2
	{
		if (out == null || out == this)
		{
			var a1 = this[1];
			this[1] = this[2];
			this[2] = a1;

			return untyped this;
		} else {
			out[0] = this[0];
			out[1] = this[2];
			out[2] = this[1];
			out[3] = this[3];

			return out;
		}
	}

	/**
		Inverts the values of `this` matrix, and stores the results on `out`;
		If `out` is null, it inverts its own value.
		If the inverse cannot be computed, it returns `null` and no value is changed.
	**/
	public function invert(?out:Mat2):Mat2
	{
		var a0 = this[0], a1 = this[1], a2 = this[2], a3 = this[3];
		var det = a0 * a3 - a2 * a1;

		if (!det)
			return null;

		det = 1. / det;

		if (out == null) out = untyped this;
		out[0] = a3 * det;
		out[1] = -a1 * det;
		out[2] = -a2 * det;
		out[3] = a0 * det;

		return out;
	}

	/**
		Calculates de adjugate of a Mat2.
		If `out` is null, it modifies the value in place
	**/
	public function adjoint(?out:Mat2):Mat2
	{
		if (out == null) out = untyped this;
		var a0 = this[0];
		out[0] = this[3];
		out[1] = -this[1];
		out[2] = -this[2];
		out[3] = a0;

		return out;
	}

	/**
		Calculates the determinant of a Mat2
	**/
	public inline function determinant()
	{
		return this[0] * this[3] - this[2] * this[1];
	}

	/**
		Multiplies two Mat2
		If `out` is null, it modifies the `this` matrix in place
	**/
	public function mul(to:Mat2, ?out:Mat2):Mat2
	{
		var a0 = this[0], a1 = this[1], a2 = this[2], a3 = this[3];
		var b0 = to[0], b1 = to[1], b2 = to[2], b3 = to[3];
		if (out == null) out = untyped this;
		out[0] = a0 * b0 + a1 * b2;
		out[1] = a0 * b1 + a1 * b3;
		out[2] = a2 * b0 + a3 * b2;
		out[3] = a2 * b1 + a3 * b3;
		return out;
	}

	@:op(A*B) public static inline function opMul(a:Mat2, b:Mat2):Mat2
	{
		return a.mul(b, mkmat());
	}

	/**
		Rotates a mat2 by the given angle, in radians.
		If `out` is null, it modifies the `this` matrix in place.
	**/
	public function rotate(rad:Rad, ?out:Mat2):Mat2
	{
		var a0 = this[0], a1 = this[1], a2 = this[2], a3 = this[3], s = rad.sin(), c = rad.cos();
		if (out == null) out = untyped this;
		out[0] = a0 * c + a1 * s;
		out[1] = a0 * -s + a1 * c;
		out[2] = a2 * c + a3 * s;
		out[3] = a2 * -s + a3 * c;
		return out;
	}

}

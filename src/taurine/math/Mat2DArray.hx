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
abstract Mat2DArray(SingleVector)
{
	/**
		Creates a new Mat2DArray with the given size.
		All elements will be 0, and not identity matrices
	 **/
	@:extern public inline function new(len:Int)
	{
		this = SingleVector.alloc(len << 3); //WARNING: because of the storage overhead, access isn't aligned!
	}

	/**
		The number of Mat2D elements contained in this array
	 **/
	public var length(get,never):Int;

	@:extern private inline function get_length():Int
	{
		return Std.int(this.length >>> 3);
	}

	@:extern private inline function t():Mat2DArray return untyped this; //get `this` as the abstract type

	/**
		Reinterpret `this` array as its first `Mat2D`
	 **/
	@:extern inline public function first():Mat2D
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
		return this[(index << 3) + nth];
	}

	/**
		Sets the `nth` val of `this` Matrix at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function setVal(index:Int, nth:Int, v:Single):Single
	{
		return this[(index << 3) + nth] = v;
	}

	/**
		Returns the value of `this` Matrix at `index`, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function matval(index:Int, row:Int, column:Int):Single
	{
		return this[(index << 3) + ( (row << 1) + column)];
	}

	/**
		Sets the value of `this` Matrix at `index`, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function setMatval(index:Int, row:Int, column:Int, v:Single):Single
	{
		return this[ (index << 3) + ( (row << 1) + column)] = v;
	}

	/**
		Creates a copy of the current Mat2DArray and returns it
	 **/
	public function copy():Mat2DArray
	{
		var len = this.length;
		var ret = new Mat2DArray(Std.int(len >>> 3));
		SingleVector.blit(this, 0, ret.getData(), 0, len);
		return ret;
	}

	/**
		Clones the matrix at `index`
	**/
	public function cloneAt(index:Int):Mat2D
	{
		var out = Mat2D.mk();
		index <<= 3;
		for (i in 0...6)
			out[i] = this[index+i];
		return out;
	}

	/**
		Copies Mat2D at `index` to `out`, at `outIndex`
		Returns `out` object
	 **/
	public function copyTo(index:Int, out:Mat2DArray, outIndex:Int)
	{
		index <<= 3; outIndex = outIndex << 3;
		for (i in 0...6)
			out[outIndex + i] = this[index + i];
		return out;
	}

	/**
		Set the Mat2D at `index` to the identity matrix.

		Returns itself
	 **/
	public function identity(index:Int):Mat2DArray
	{
		index = index << 3;
		this[index] = this[index+3] = 1;
		this[index+1] = this[index+2] = this[index+4] =	this[index+5] = 0;
		return t();
	}

	/**
		Inverts current matrix at `index` and stores the value at `outIndex` on `out` matrix array

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2DArray`; If the operation fails, returns `null`
	 **/
	@:extern public inline function invert(index:Int, ?out:Mat2DArray, outIndex:Int=-1):Mat2DArray
  {
    return invert_impl(index, out, outIndex);
  }

	private function invert_impl(index:Int, out:Mat2DArray, outIndex:Int):Mat2DArray
	{
		if (out == null)
		{
			out = t();
      outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 3;
		index <<= 3;

		return invert_inline(index,outIndex,out);
	}

	@:extern inline private function invert_inline(index:Int, outIndex:Int, out:Mat2DArray):Mat2DArray
	{
		var aa = this[index+0], ab = this[index+1], ac = this[index+2], ad = this[index+3],
				atx = this[index+4], aty = this[index+5];

		var det = aa * ad - ab * ac;
		if (det == 0)
		{
			return null;
		} else {
			det = 1.0 / det;

			out[outIndex+0] = ad * det;
			out[outIndex+1] = -ab * det;
			out[outIndex+2] = -ac * det;
			out[outIndex+3] = aa * det;
			out[outIndex+4] = (ac * aty - ad * atx) * det;
			out[outIndex+5] = (ab * atx - aa * aty) * det;

			return out;
		}
	}

	/**
		Calculates de determinant of the Mat2D at `index`
	 **/
	public function determinant(index:Int):Float
	{
		index <<= 3;
		return this[index] * this[index+3] - this[index+1] * this[index+2];
	}

	@:extern inline public function det(index):Float
	{
		return determinant(index);
	}

	/**
		Multiplies current matrix at `index` with matrix array `b` at `bIndex`,
		and stores the value at `outIndex` on `out` matrix array

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2DArray`
	 **/
	@:extern public inline function mul(index:Int, b:Mat2DArray, bIndex:Int, ?out:Mat2DArray, outIndex:Int=-1):Mat2DArray
  {
    return mul_impl(index, b, bIndex, out, outIndex);
  }

	private function mul_impl(index:Int, b:Mat2DArray, bIndex:Int, out:Mat2DArray, outIndex:Int):Mat2DArray
	{
		if (out == null)
		{
			out = t();
      outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 3;
		index <<= 3;
		bIndex <<= 3;

		multiply_inline(index,b,bIndex,outIndex,out);
		return out;
	}

	@:extern inline private function multiply_inline(index:Int, b:Mat2DArray, bIndex:Int, outIndex:Int, out:Mat2DArray)
	{
		var aa = this[index+0], ab = this[index+1], ac = this[index+2], ad = this[index+3],
				atx = this[index+4], aty = this[index+5],
				ba = b[bIndex+0], bb = b[bIndex+1], bc = b[bIndex+2], bd = b[bIndex+3],
				btx = b[bIndex+4], bty = b[bIndex+5];

		out[outIndex+0] = aa*ba + ab*bc;
		out[outIndex+1] = aa*bb + ab*bd;
		out[outIndex+2] = ac*ba + ad*bc;
		out[outIndex+3] = ac*bb + ad*bd;
		out[outIndex+4] = ba*atx + bc*aty + btx;
		out[outIndex+5] = bb*atx + bd*aty + bty;
	}

	/**
		Translates the Mat2D at `index` with `x` and `y`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2DArray`
	 **/
	@:extern public inline function translate(index:Int, x:Single, y:Single, ?out:Mat2DArray, outIndex:Int=-1):Mat2DArray
  {
    return translate_impl(index, x, y, out, outIndex);
  }

	private function translate_impl(index:Int, x:Single, y:Single, ?out:Mat2DArray, outIndex:Int):Mat2DArray
	{
		if (out == null)
		{
			out = t();
      outIndex = index;
		}

		index <<= 3;
		outIndex = outIndex << 3;
		out[outIndex+0] = this[index+0];
		out[outIndex+1] = this[index+1];
		out[outIndex+2] = this[index+2];
		out[outIndex+3] = this[index+3];
		out[outIndex+4] = this[index+4] + x;
		out[outIndex+5] = this[index+5] + y;

		return out;
	}

	/**
		Translates the Mat2D with the `vec` Vec2
		@see Mat2DArray#translate
	 **/
	@:extern inline public function translatev(index:Int, vec:Vec2, ?out:Mat2DArray, outIndex:Int=-1):Mat2DArray
	{
		return translate(index,vec[0],vec[1],out,outIndex);
	}

	/**
		Scales the Mat2D by `x`, `y`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2DArray`
	 **/
	@:extern public inline function scale(index:Int, vx:Single, vy:Single, ?out:Mat2DArray, outIndex:Int=-1):Mat2DArray
  {
    return scale_impl(index, vx, vy, out, outIndex);
  }

	private function scale_impl(index:Int, vx:Single, vy:Single, out:Mat2DArray, outIndex:Int):Mat2DArray
	{
		if (out == null)
		{
			out = t();
      outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 3;
		index <<= 3;

		out[outIndex+0] = this[index+0] * vx;
		out[outIndex+1] = this[index+1] * vy;
		out[outIndex+2] = this[index+2] * vx;
		out[outIndex+3] = this[index+3] * vy;
		out[outIndex+4] = this[index+4] * vx;
		out[outIndex+5] = this[index+5] * vy;
		return out;
	}

	@:extern inline public function scalev(index:Int, vec:Vec2, ?out:Mat2DArray, outIndex:Int=-1):Mat2DArray
	{
		return scale(index,vec[0],vec[1],out,outIndex);
	}

	/**
		Rotates `this` matrix by the given angle at the (`x`, `y`) vector

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat2DArray`
	 **/
	@:extern public inline function rotate(index:Int, angle:Rad, ?out:Mat2DArray, outIndex:Int=-1):Mat2DArray
  {
    return rotate_impl(index, angle, out, outIndex);
  }

	private function rotate_impl(index:Int, angle:Rad, out:Mat2DArray, outIndex:Int):Mat2DArray
	{
		if (out == null)
		{
			out = t();
      outIndex = index;
		}

		// force outIndex to be Int, not Null<Int>
		outIndex = outIndex << 3;
		index <<= 3;

		var aa = this[index+0],
				ab = this[index+1],
				ac = this[index+2],
				ad = this[index+3],
				atx = this[index+4],
				aty = this[index+5],
				st = angle.sin(),
				ct = angle.cos();

		out[outIndex+0] = aa*ct + ab*st;
		out[outIndex+1] = -aa*st + ab*ct;
		out[outIndex+2] = ac*ct + ad*st;
		out[outIndex+3] = -ac*st + ct*ad;
		out[outIndex+4] = ct*atx + st*aty;
		out[outIndex+5] = ct*aty - st*atx;
		return out;
	}

	public function eq(index:Int, b:Mat2DArray, bIndex:Int):Bool
	{
		index <<= 3; bIndex <<= 3;
		if (this == b.getData() && index == bIndex)
			return true;
		else if (this == null || b == null)
			return false;

		for(i in 0...6)
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
		var len = (this.length >>> 3);
		if (len << 3 > this.length) len--; //be safe
		buf.add('mat2d[');
		buf.add(len);
		buf.add(']\n{');
		var support = [], maxn = 0;
		for (i in 0...len)
		{
			buf.add('\n\t');
			buf.add('mat2d(');
			for (j in 0...6)
			{
				var s = support[ j ] = this[ (i << 3) + j ] + "";
				if (s.length > maxn) maxn = s.length;
			}

			var fst = true;
			for (j in 0...3)
			{
				if (fst) fst = false; else buf.add('\n\t      ');
				for (k in 0...2)
				{
					buf.add(StringTools.rpad(support[ (j * 2) + k ], " ", maxn));
					buf.add(", ");
				}
				buf.add( j == 2 ? "1" : "0");
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

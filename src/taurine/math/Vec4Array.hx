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
	4 Dimensional Vector Array
**/
abstract Vec4Array(SingleVector)
{
	/**
		Creates a new Vec4Array with the given size.
	**/
	@:extern public inline function new(len:Int)
	{
		this = SingleVector.alloc(len << 2);
	}

	/**
		The number of Vec4 elements contained in this array
	**/
	public var length(get,never):Int;

	@:extern private inline function get_length():Int
	{
		return this.length >>> 2;
	}

	@:extern private inline function t():Vec4Array return untyped this; //get `this` as the abstract type

	/**
		Reinterpret `this` array as its first `Vec4`
	**/
	@:extern inline public function first():Vec4
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Creates a copy of the current Vec4Array and returns it
	**/
	public function copy():Vec4Array
	{
		var len = this.length;
		var ret = new Vec4Array(len >>> 2);
		SingleVector.blit(this, 0, ret.getData(), 0, len);
		return ret;
	}

	/**
		Copies Vec4 at `index` to `out`, at `outIndex`
			Returns `out` object
	**/
	public function copyTo(index:Int, out:Vec4Array, outIndex:Int)
	{
		index <<= 2; outIndex <<= 2;
		out[outIndex] = this[index];
		out[outIndex+1] = this[index+1];
		out[outIndex+2] = this[index+2];
		out[outIndex+3] = this[index+3];
		return out;
	}

	/**
		Sets the components of `this` Vec4 at `index`
			Returns itself
	**/
	public function setAt(index:Int, x:Single, y:Single, z:Single, w:Single):Vec4Array
	{
		index <<= 2;
		this[index] = x;
		this[index+1] = y;
		this[index+2] = z;
		this[index+3] = w;
		return t();
	}

	/**
		Adds `this` Vec4 at `index` to `b` at `bIndex`, and stores the result at `out` (at `outIndex`)

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function add(index:Int, b:Vec4Array, bIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2;
		bIndex <<= 2;
		outIndex <<= 2;

		out[outIndex] = this[index] + b[bIndex];
		out[outIndex+1] = this[index+1] + b[bIndex+1];
		out[outIndex+2] = this[index+2] + b[bIndex+2];
		out[outIndex+3] = this[index+3] + b[bIndex+3];
		return out;
	}

	/**
		Subtracts `this` Vec4 at `index` to `b` at `bIndex`, and stores the result at `out` (at `outIndex`)

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function sub(index:Int, b:Vec4Array, bIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2;
		bIndex <<= 2;
		outIndex <<= 2;

		out[outIndex] = this[index] - b[bIndex];
		out[outIndex+1] = this[index+1] - b[bIndex+1];
		out[outIndex+2] = this[index+2] - b[bIndex+2];
		out[outIndex+3] = this[index+3] - b[bIndex+3];
		return out;
	}

	/**
		Multiplies `this` Vec4 at `index` to `b` at `bIndex`, and stores the result at `out` (at `outIndex`)

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function mul(index:Int, b:Vec4Array, bIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2;
		bIndex <<= 2;
		outIndex <<= 2;

		out[outIndex] = this[index] * b[bIndex];
		out[outIndex+1] = this[index+1] * b[bIndex+1];
		out[outIndex+2] = this[index+2] * b[bIndex+2];
		out[outIndex+3] = this[index+3] * b[bIndex+3];
		return out;
	}

	/**
		Divides `this` Vec4 at `index` to `b` at `bIndex`, and stores the result at `out` (at `outIndex`)

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function div(index:Int, b:Vec4Array, bIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2;
		bIndex <<= 2;
		outIndex <<= 2;

		out[outIndex] = this[index] / b[bIndex];
		out[outIndex+1] = this[index+1] / b[bIndex+1];
		out[outIndex+2] = this[index+2] / b[bIndex+2];
		out[outIndex+3] = this[index+3] / b[bIndex+3];
		return out;
	}

	/**
		Returns the maximum of two vec4's

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function maxFrom(index:Int, b:Vec4Array, bIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2;
		bIndex <<= 2;
		outIndex <<= 2;

		var t0 = this[index], t1 = this[index+1], t2 = this[index+2], t3 = this[index+3];
		var b0 = b[bIndex], b1 = b[bIndex+1], b2 = b[bIndex+2], b3 = b[bIndex+3];
		out[outIndex] = t0 > b0 ? t0 : b0;
		out[outIndex+1] = t1 > b1 ? t1 : b1;
		out[outIndex+2] = t2 > b2 ? t2 : b2;
		out[outIndex+3] = t3 > b3 ? t3 : b3;
		return out;
	}

	/**
		Returns the minimum of two vec4's

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function minFrom(index:Int, b:Vec4Array, bIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2;
		bIndex <<= 2;
		outIndex <<= 2;

		var t0 = this[index], t1 = this[index+1], t2 = this[index+2], t3 = this[index+3];
		var b0 = b[bIndex], b1 = b[bIndex+1], b2 = b[bIndex+2], b3 = b[bIndex+3];
		out[outIndex] = t0 < b0 ? t0 : b0;
		out[outIndex+1] = t1 < b1 ? t1 : b1;
		out[outIndex+2] = t2 < b2 ? t2 : b2;
		out[outIndex+3] = t3 < b3 ? t3 : b3;
		return out;
	}

	/**
		Calculates the maximum of all elements in `this` Vec4Array,
		starting from `startIndex` until `endIndex` (`endIndex` included),
		and stores the result on `out` (at `outIndex`)

			If `endIndex` is less than 0, it will be implicit to be len - endIndex_value;
			If `endIndex` is greater than length, it will be length - 1
			Returns the changed `Vec4Array`
	**/
	public function max(startIndex:Int=0, endIndex:Int=-1, out:Vec4Array, outIndex:Int):Vec4Array
	{
		var mx, my, mz, mw;
		mx = my = mz = mw = FastMath.NEGATIVE_INFINITY;

		var len = this.length >>> 2 - 1;
		if (len < 0) return null;

		if (endIndex < 0)
			endIndex = len + endIndex + 1;
		if (endIndex > len)
			endIndex = len;

		for (i in startIndex...endIndex)
		{
			var tmp = this[ (i << 2) + 0 ];
			if (mx < tmp) mx = tmp;
			tmp = this[ (i << 2) + 1 ];
			if (my < tmp) my = tmp;
			tmp = this[ (i << 2) + 2 ];
			if (mz < tmp) mz = tmp;
			tmp = this[ (i << 2) + 3 ];
			if (mw < tmp) mw = tmp;
		}
	}

	/**
		Calculates the minimum of all elements in `this` Vec4Array,
		starting from `startIndex` until `endIndex` (`endIndex` included),
		and stores the result on `out` (at `outIndex`)

			If `endIndex` is less than 0, it will be implicit to be len - endIndex_value;
			If `endIndex` is greater than length, it will be length - 1
			Returns the changed `Vec4Array`
	**/
	public function min(startIndex:Int=0, endIndex:Int=-1, out:Vec4Array, outIndex:Int):Vec4Array
	{
		var mx, my, mz, mw;
		mx = my = mz = mw = FastMath.NEGATIVE_INFINITY;

		var len = this.length >>> 2 - 1;
		if (len < 0) return null;

		if (endIndex < 0)
			endIndex = len + endIndex + 1;
		if (endIndex > len)
			endIndex = len;
		for (i in startIndex...endIndex)
		{
			var tmp = this[ (i << 2) + 0 ];
			if (mx > tmp) mx = tmp;
			tmp = this[ (i << 2) + 1 ];
			if (my > tmp) my = tmp;
			tmp = this[ (i << 2) + 2 ];
			if (mz > tmp) mz = tmp;
			tmp = this[ (i << 2) + 3 ];
			if (mw > tmp) mw = tmp;
		}
	}

	/**
		Scales a Vec4 by a scalar number

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function scale(index:Int, scalar:Single, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2;
		outIndex <<= 2;

		out[outIndex] = this[index] * scalar;
		out[outIndex+1] = this[index+1] * scalar;
		out[outIndex+2] = this[index+2] * scalar;
		out[outIndex+3] = this[index+3] * scalar;
		return out;
	}

	/**
		Calculates the euclidian distance between two Vec4's
	**/
	public function dist(index:Int, b:Vec4Array, bIndex:Int):Float
	{
		index <<= 2; bIndex <<= 2;
		var a0 = this[index], a1 = this[index+1], a2 = this[index+2], a3 = this[index+3];
		var b0 = b[bIndex], b1 = b[bIndex+1], b2 = b[bIndex+2], b3 = b[bIndex+3];
		a0 -= b0; a1 -= b1; a2 -= b2; a3 -= b3;
		return FastMath.sqrt(a0*a0 + a1*a1 + a2*a2 + a3*a3);
	}

	/**
		Calculates the squared euclidian distance between two Vec4's
	**/
	public function sqrdist(index:Int, b:Vec4Array, bIndex:Int):Float
	{
		index <<= 2; bIndex <<= 2;
		var a0 = this[index], a1 = this[index+1], a2 = this[index+2], a3 = this[index+3];
		var b0 = b[bIndex], b1 = b[bIndex+1], b2 = b[bIndex+2], b3 = b[bIndex+3];
		a0 -= b0; a1 -= b1; a2 -= b2; a3 -= b3;
		return (a0*a0 + a1*a1 + a2*a2 + a3*a3);
	}

	/**
		Calculates the length of a `Vec4` at `index`
	**/
	public function lengthAt(index:Int):Float
	{
		index <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		return FastMath.sqrt(x*x + y*y + z*z + w*w);
	}

	/**
		Calculates the squared length of a `Vec4` at `index`
	**/
	public function sqrlenAt(index:Int):Float
	{
		index <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		return (x*x + y*y + z*z + w*w);
	}

	/**
		Negates the components of a Vec4 at `index`

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function neg(index:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2; outIndex <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		out[outIndex] = -x;
		out[outIndex+1] = -y;
		out[outIndex+2] = -z;
		out[outIndex+3] = -w;
		return out;
	}

	/**
		Normalize a Vec4Array at `index`

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function normalize(index:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2; outIndex <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		var len = x*x + y*y + z*z + w*w;
		if (len > 0)
		{
			len = FastMath.invsqrt(len);
			out[outIndex] = x * len;
			out[outIndex+1] = y * len;
			out[outIndex+2] = z * len;
			out[outIndex+3] = w * len;
		}

		return out;
	}

	/**
		Calculates the dot product of two Vec4's
	**/
	public function dot(index:Int, b:Vec4Array, bIndex:Int):Float
	{
		index <<= 2; bIndex <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		return b[bIndex] * x + b[bIndex+1] * y + b[bIndex+2] * z + b[bIndex+3] * w;
	}

	/**
		Performs a linear interpolation between two Vec4's

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function lerp(index:Int, to:Vec4Array, toIndex:Int, t:Float, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2; outIndex <<= 2; bIndex <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		var bx = to[toIndex], by = to[toIndex+1], bz = to[toIndex+2], bw = to[toIndex+3];

		out[outIndex] = x + t * (bx - x);
		out[outIndex+1] = y + t * (by - y);
		out[outIndex+2] = z + t * (bz - z);
		out[outIndex+3] = w + t * (bw - w);
		return out;
	}

	/**
		Transforms the `Vec4` with a `Mat4`

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function transformMat4(index:Int, m:Mat4Array, mIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2; outIndex <<= 2; mIndex <<= 4;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		var m0 = m[mIndex], m1 = m[mIndex+1], m2 = m[mIndex + 2], m3 = m[mIndex + 3],
				m4 = m[mIndex + 4], m5 = m[mIndex + 5], m6 = m[mIndex + 6], m7 = m[mIndex + 7],
				m8 = m[mIndex + 8], m9 = m[mIndex + 9], m10 = m[mIndex + 10], m11 = m[mIndex + 11],
				m12 = m[mIndex + 12], m13 = m[mIndex + 13], m14 = m[mIndex + 14], m15 = m[mIndex + 15];
    out[outIndex+0] = m0 * x + m4 * y + m8 * z + m12 * w;
    out[outIndex+1] = m1 * x + m5 * y + m9 * z + m13 * w;
    out[outIndex+2] = m2 * x + m6 * y + m10 * z + m14 * w;
    out[outIndex+3] = m3 * x + m7 * y + m11 * z + m15 * w;

		return out;
	}

	/**
		Transforms the `Vec4` with a `Quat`

			If `out` is null, it will implicitly be considered itself;
			If `outIndex` is null, it will be considered to be the same as `index`.
			Returns the changed `Vec4Array`
	**/
	public function transformQuat(index:Int, q:QuatArray, qIndex:Int, ?out:Vec4Array, ?outIndex:Int):Vec4Array
	{
		if (out == null)
		{
			out = t();
			if (outIndex == null)
				outIndex = index;
		}
		index <<= 2; outIndex <<= 2; qIndex <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2], w = this[index+3];
		var qx = q[qIndex], qy = q[qIndex+1], qz = q[qIndex+2], qw = q[qIndex+3];
        // calculate quat * vec
    var ix = qw * x + qy * z - qz * y,
        iy = qw * y + qz * x - qx * z,
        iz = qw * z + qx * y - qy * x,
        iw = -qx * x - qy * y - qz * z;

    // calculate result * inverse quat
    out[outIndex+0] = ix * qw + iw * -qx + iy * -qz - iz * -qy;
    out[outIndex+1] = iy * qw + iw * -qy + iz * -qx - ix * -qz;
    out[outIndex+2] = iz * qw + iw * -qz + ix * -qy - iy * -qx;
		return out;
	}


	@:extern inline public function forEach(fn:Vec4Array->Int->Void):Void
	{
		var len = this.length >>> 2;
		for (i in 0...len)
		{
			fn(t(),i);
		}
	}

	public function toString():String
	{
		var buf = new StringBuf();
		var len = this.length >>> 2;
		if (len << 2 > this.length) len--; //be safe
		buf.add('vec4[');
		buf.add(len);
		buf.add(']\n{');
		for (i in 0...len)
		{
			buf.add('\n\t');
			buf.add('vec4(');
			var fst = true;
			for (j in 0...4)
			{
				if (fst) fst = false; else buf.add(", ");
				buf.add(this[ (i << 4) + j ]);
			}
			buf.add("), ");
		}
		buf.add("\n}");

		return buf.toString();
	}

}

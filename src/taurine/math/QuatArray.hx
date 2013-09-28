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
	Quaternion Array
 **/
	@:access(taurine.math)
abstract QuatArray(SingleVector)
{
	/**
		Creates a new QuatArray with the given size.
		All elements will be 0, and not identity quats
	 **/
	@:extern public inline function new(len:Int)
	{
		this = SingleVector.alloc(len << 2);
	}

	/**
		The number of Quat elements contained in this array
	 **/
	public var length(get,never):Int;

	@:extern private inline function get_length():Int
	{
		return this.length >>> 2;
	}

	@:extern private inline function t():QuatArray return untyped this; //get `this` as the abstract type

	/**
		Returns the `nth` val of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function val(index:Int, nth:Int):Single
	{
		return this[(index << 2) + nth];
	}

	/**
		Sets the `nth` val of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function setVal(index:Int, nth:Int, v:Single):Single
	{
		return this[(index << 2) + nth] = v;
	}

	/**
		Gets the `x` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function x(index:Int):Single
	{
		return this[(index << 2)];
	}

	/**
		Sets the `x` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function setx(index:Int, v:Single):Single
	{
		return this[(index << 2)] = v;
	}

	/**
		Gets the `y` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function y(index:Int):Single
	{
		return this[(index << 2)+1];
	}

	/**
		Sets the `y` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function sety(index:Int, v:Single):Single
	{
		return this[(index << 2)+1] = v;
	}

	/**
		Gets the `z` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function z(index:Int):Single
	{
		return this[(index << 2)+2];
	}

	/**
		Sets the `z` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function setz(index:Int, v:Single):Single
	{
		return this[(index << 2)+2] = v;
	}

	/**
		Gets the `w` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function w(index:Int):Single
	{
		return this[(index << 2)+3];
	}

	/**
		Sets the `w` component of `this` Quat at `index`
		Does not perform bounds check
	 **/
	@:extern inline public function setw(index:Int, v:Single):Single
	{
		return this[(index << 2)+3] = v;
	}

	/**
		Clones the Quat at `index`
	**/
	public function cloneAt(index:Int):Quat
	{
		var out = Quat.mk();
		index <<= 2;
		out[0] = this[index];
		out[1] = this[index+1];
		out[2] = this[index+2];
		out[3] = this[index+3];
		return out;
	}

	/**
		Reinterpret `this` array as its first `Quat`
	 **/
	@:extern inline public function first():Quat
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		@see rotationTo
	 **/
	public function rotationTov(index:Int, a:Vec3Array, aIndex:Int, b:Vec3Array, bIndex:Int):QuatArray
	{
		bIndex <<= 2; aIndex <<= 2;
		var ax = a[aIndex], ay = a[aIndex+1], az = a[aIndex+2];
		var bx = b[bIndex], by = b[bIndex+1], bz = b[bIndex+2];
		return rotationTo(index,ax,ay,az,bx,by,bz);
	}

	/**
		Sets a Quaternion to represent the shortes rotation from one Vec3 to another

		Both vectors are assumed to be unit length

		`a` - The initial vector
		`b` - The destination vector
		Returns itself
	 **/
	public function rotationTo(index:Int, ax:Single,ay:Single,az:Single, bx:Single,by:Single,bz:Single):QuatArray
	{
		//x 1 0 0
		//y 0 1 0
		var dot = bx * ax + by * ay + bz * az;
		index <<= 2;
		if (dot < -0.999999) {
			// vec3.cross(tmpvec3, xUnitVec3, a);
			var tmp0 = .0, tmp1 = - az, tmp2 = ay;
			var tmplen = FastMath.sqrt(tmp1*tmp1+tmp2*tmp2);
			if (tmplen < 0.000001)
			{
				// vec3.cross(tmpvec3, yUnitVec3, a);
				tmp0 = az;
				tmp1 = 0;
				tmp2 = -ax;
			}
			// vec3.normalize(tmpvec3, tmpvec3);
			var len = tmp0*tmp0 + tmp1*tmp1 + tmp2*tmp2;
			if (len > 0)
			{
				len = FastMath.invsqrt(len);
				tmp0 = tmp0 * len;
				tmp1 = tmp1 * len;
				tmp2 = tmp2 * len;
			}
			// quat.setAxisAngle(out, tmpvec3, Math.PI);
			var r = MacroMath.reduce(Math.PI * .5);
			var s = FastMath.sin(r);
			this[index] = s * tmp0;
			this[index+1] = s * tmp1;
			this[index+2] = s * tmp2;
			this[index+3] = FastMath.cos(r);
			return t();
		} else if (dot > 0.999999) {
			this[index] = this[index+1] = this[index+2] = 0;
			this[index+3] = 1;
			return t();
		} else {
			// vec3.cross(tmpvec3, a, b);
			var tmp0 = ay * bz - az * by, tmp1 = az * bx - ax * bz, tmp2 = ax * by - ay * bx;
			this[index] = tmp0;
			this[index+1] = tmp1;
			this[index+2] = tmp2;
			this[index+3] = 1 + dot;
			return normalize_internal(index,t(),index);
		}
	}

	/**
		Set the specified quaternion with values corresponding to the given
		axes. Each axis is a `Vec3` and is expected to be unit length and
		perpendicular to all other specified axes.

		`view` - The vector representing the viewing direction
		`right` - The vector representing the local `right` direction
		`up` - The vector representing the local `up` direction
	 **/
	public function setAxes(index:Int, view:Vec3Array, vindex:Int, right:Vec3Array, rindex:Int, up:Vec3Array, uindex:Int):QuatArray
	{
		index <<= 2; vindex <<= 2; rindex <<= 2; uindex <<= 2;
		var m0 = right[rindex];
		var m3 = right[rindex+1];
		var m6 = right[rindex+2];

		var m1 = up[uindex];
		var m4 = up[uindex+1];
		var m7 = up[uindex+2];

		var m2 = view[vindex];
		var m5 = view[vindex+1];
		var m8 = view[vindex+2];

		//called an internal version to avoid allocating a temporary structure
		fromMat3_internal(index,m0,m1,m2,m3,m4,m5,m6,m7,m8);
		return normalize_internal(index,t(),index);
	}

	private function fromMat3_internal(index:Int, m0:Single, m1:Single, m2:Single, m3:Single, m4:Single, m5:Single, m6:Single, m7:Single, m8:Single):QuatArray
	{
		// Algorithm in Ken Shoemake's article in 1987 SIGGRAPH course notes
		// article "Quaternion Calculus and Fast Animation".
		var fTrace = m0 + m4 + m8;

		if ( fTrace > 0.0 ) {
			// |w| > 1/2, may as well choose w > 1/2
			var fRoot = Math.sqrt(fTrace + 1.0);  // 2w
			this[index+3] = 0.5 * fRoot;
			fRoot = 0.5/fRoot;  // 1/(4w)
			this[index+0] = (m7-m5)*fRoot;
			this[index+1] = (m2-m6)*fRoot;
			this[index+2] = (m3-m1)*fRoot;
		} else {
			// |w| <= 1/2
			var i = 0;
			if ( m4 > m0 )
			{
				i = 1;
				if ( m8 > m4 )
					i = 2;
			} else if ( m8 > m0 ) {
				i = 2;
			}
			var j = (i+1)%3;
			var k = (i+2)%3;
			var mi3i, mj3j, mk3k, mk3j, mj3k, mj3i, mi3j, mk3i, mi3k;
			switch(i)
			{
				case 0:
					//i = 0; j = 1; k = 2
					mi3i = m0; mj3j = m4; mk3k = m8;
					mk3j = m7; mj3k = m5;
					mj3i = m3; mi3j = m1;
					mk3i = m6; mi3k = m2;
				case 1:
					//i = 1; j = 2; k = 0
					mi3i = m4; mj3j = m8; mk3k = m0;
					mk3j = m2; mj3k = m6;
					mj3i = m7; mi3j = m5;
					mk3i = m1; mi3k = m3;
				default: //avoid uninitialized errors
					//i = 2; j = 0; k = 1
					mi3i = m8; mj3j = m0; mk3k = m4;
					mk3j = m3; mj3k = m1;
					mj3i = m2; mi3j = m6;
					mk3i = m5; mi3k = m7;
			}
			// fRoot = Math.sqrt(m[i*3+i]-m[j*3+j]-m[k*3+k] + 1.0);
			// out[i] = 0.5 * fRoot;
			// fRoot = 0.5 / fRoot;
			// out[3] = (m[k*3+j] - m[j*3+k]) * fRoot;
			// out[j] = (m[j*3+i] + m[i*3+j]) * fRoot;
			// out[k] = (m[k*3+i] + m[i*3+k]) * fRoot;

			var fRoot = FastMath.sqrt(mi3i-mj3j-mk3k + 1.0);
			this[index+i] = 0.5 * fRoot;
			fRoot = 0.5 / fRoot;
			this[index+3] = (mk3j - mj3k) * fRoot;
			this[index+j] = (mj3i + mi3j) * fRoot;
			this[index+k] = (mk3i + mi3k) * fRoot;
		}
		return t();
	}

	/**
		Creates a copy of the current QuatArray and returns it
	 **/
	public function copy():QuatArray
	{
		var len = this.length;
		var ret = new QuatArray(len >>> 2);
		SingleVector.blit(this, 0, ret.getData(), 0, len);
		return ret;
	}

	/**
		Copies Quat at `index` to `out`, at `outIndex`
		Returns `out` object
	 **/
	public function copyTo(index:Int, out:QuatArray, outIndex:Int)
	{
		index <<= 2; outIndex = outIndex << 2;
		out[outIndex] = this[index];
		out[outIndex+1] = this[index+1];
		out[outIndex+2] = this[index+2];
		out[outIndex+3] = this[index+3];
		return out;
	}

	/**
		Set the components of a Quat at `index` to the given values

		Returns itself
	 **/
	public function setAt(index:Int, x:Single, y:Single, z:Single, w:Single):QuatArray
	{
		index <<= 2;
		this[index] = x;
		this[index+1] = y;
		this[index+2] = z;
		this[index+3] = w;
		return t();
	}

	/**
		Set the Quat at `index` to the identity quaternion.

		Returns itself
	 **/
	public function identity(index:Int):QuatArray
	{
		index = index << 2;
		this[index] = this[index+1] = this[index+2] = 0;
		this[index+3] = 1;
		return t();
	}

	/**
		Sets a Quat at `index` from the given angle (`rad`) and rotation `axis`

		`index` - The index from `this` QuatArray - where the result will be stored
		`axis` - The axis around which to rotate
		`rad` - The angle in radians
		Returns itself
	 **/
	public function setAxisAngle(index:Int, axisX:Single, axisY:Single, axisZ:Single, rad:Rad):QuatArray
	{
		index <<= 2;
		var rad = rad.float() * .5;
		var s = FastMath.sin(rad);
		this[index] = s * axisX;
		this[index+1] = s * axisY;
		this[index+2] = s * axisZ;
		this[index+3] = FastMath.cos(rad);
		return t();
	}

	@:extern inline public function setAxisAngle_v(index:Int, axis:Vec3, rad:Rad):QuatArray
	{
		return setAxisAngle(index,axis[0],axis[1],axis[2],rad);
	}

	/**
		Adds `this` Quat at `index` to `b` at `bIndex`, and stores the result at `out` (at `outIndex`)

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `QuatArray`
	 **/
	@:extern inline public function add(index:Int, b:QuatArray, bIndex:Int, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return cast Vec4Array.add(cast t(), index, cast b, bIndex, cast out, outIndex);
	}

	/**
		Multiplies `this` Quat at `index` with `b` at `bIndex`, and store the result at `out` (at `outIndex`)

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `QuatArray`
	 **/
	@:extern public inline function mul(index:Int, b:QuatArray, bIndex:Int, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return mul_impl(index, b, bIndex, out, outIndex);
	}

	private function mul_impl(index:Int, b:QuatArray, bIndex:Int, out:QuatArray, outIndex:Int):QuatArray
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}
		index <<= 2; bIndex <<= 2; outIndex = outIndex << 2;
		var ax = this[index+0], ay = this[index+1], az = this[index+2], aw = this[index+3],
				bx = b[bIndex+0], by = b[bIndex+1], bz = b[bIndex+2], bw = b[bIndex+3];

		out[outIndex+0] = ax * bw + aw * bx + ay * bz - az * by;
		out[outIndex+1] = ay * bw + aw * by + az * bx - ax * bz;
		out[outIndex+2] = az * bw + aw * bz + ax * by - ay * bx;
		out[outIndex+3] = aw * bw - ax * bx - ay * by - az * bz;
		return out;
	}

	/**
		Scales a Quat by a scalar number

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `QuatArray`
	 **/
	@:extern inline public function scale(index:Int, scalar:Single, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return cast Vec4Array.scale(cast t(), index, scalar, cast out, outIndex);
	}

	/**
		Rotates a quaternion by the given angle about the x axis
	 **/
	@:extern public inline function rotateX(index:Int, rad:Rad, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return rotateX_impl(index, rad, out, outIndex);
	}

	private function rotateX_impl(index:Int, rad:Rad, out:QuatArray, outIndex:Int):QuatArray
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}
		index <<= 2; outIndex = outIndex << 2;
		var rad = rad.float() * .5;
		var ax = this[index+0], ay = this[index+1], az = this[index+2], aw = this[index+3],
				bx = FastMath.sin(rad), bw = FastMath.cos(rad);

		out[outIndex+0] = ax * bw + aw * bx;
		out[outIndex+1] = ay * bw + az * bx;
		out[outIndex+2] = az * bw - ay * bx;
		out[outIndex+3] = aw * bw - ax * bx;
		return out;
	}

	/**
		Rotates a quaternion by the given angle about the y axis
	 **/
	@:extern public inline function rotateY(index:Int, rad:Rad, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return rotateY_impl(index, rad, out, outIndex);
	}

	private function rotateY_impl(index:Int, rad:Rad, out:QuatArray, outIndex:Int):QuatArray
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}
		index <<= 2; outIndex = outIndex << 2;
		var rad = rad.float() * .5;
		var ax = this[index+0], ay = this[index+1], az = this[index+2], aw = this[index+3],
				by = FastMath.sin(rad), bw = FastMath.cos(rad);

		out[outIndex+0] = ax * bw - az * by;
		out[outIndex+1] = ay * bw + aw * by;
		out[outIndex+2] = az * bw + ax * by;
		out[outIndex+3] = aw * bw - ay * by;
		return out;
	}

	/**
		Rotates a quaternion by the given angle about the z axis
	 **/
	@:extern public inline function rotateZ(index:Int, rad:Rad, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return rotateZ_impl(index, rad, out, outIndex);
	}

	private function rotateZ_impl(index:Int, rad:Rad, out:QuatArray, outIndex:Int):QuatArray
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}
		index <<= 2; outIndex = outIndex << 2;
		var rad = rad.float() * .5;
		var ax = this[index+0], ay = this[index+1], az = this[index+2], aw = this[index+3],
				bz = FastMath.sin(rad), bw = FastMath.cos(rad);

		out[outIndex+0] = ax * bw + ay * bz;
		out[outIndex+1] = ay * bw - ax * bz;
		out[outIndex+2] = az * bw + aw * bz;
		out[outIndex+3] = aw * bw - az * bz;
		return out;
	}

	/**
		Calculates the w component of a Quat from the x,y and z components.
		Assumes that a quaternion is 1 unit in length
		Any existing W component will be ignored
		Modifies the value in-place and returns it
	 **/
	public function calculateW(index:Int):QuatArray
	{
		index <<= 2;
		var x = this[index], y = this[index+1], z = this[index+2];

		var val = 1.0 - x*x - y*y - z*z;
		this[index+3] = -FastMath.sqrt( val < 0 ? -val : val );
		return t();
	}

	/**
		Calculates the dot product of two quat's
	 **/
	@:extern inline public function dot(index:Int, b:QuatArray, bIndex:Int):Float
	{
		return Vec4Array.dot(cast t(), index, cast b, bIndex);
	}

	/**
		Performs a linear interpolation between two quat's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `QuatArray`
	 **/
	@:extern inline public function lerp(index:Int, to:QuatArray, toIndex:Int, t:Float, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return cast Vec4Array.lerp(this, index, cast to, toIndex, t, cast out, outIndex);
	}

	/**
		Performs a spherical linear interpolation between two quat's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `QuatArray`
	 **/
	@:extern inline public function slerp(index:Int, to:QuatArray, toIndex:Int, amount:Float, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
    return slerp_impl(index,to,toIndex,amount,out,outIndex);
  }

  private function slerp_impl(index:Int, to:QuatArray, toIndex:Int, amount:Float, out:QuatArray, outIndex:Int):QuatArray
  {
		if (out == null)
		{
			out = t();
			outIndex = index;
		}
		index <<= 2; toIndex <<= 2; outIndex = outIndex << 2;
		// benchmarks:
		//    http://jsperf.com/quaternion-slerp-implementations

		var ax = this[index+0], ay = this[index+1], az = this[index+2], aw = this[index+3],
				bx = to[toIndex+0], by = to[toIndex+1], bz = to[toIndex+2], bw = to[toIndex+3];

		var        omega, cosom, sinom, scale0, scale1;

		// calc cosine
		cosom = ax * bx + ay * by + az * bz + aw * bw;
		// adjust signs (if necessary)
		if ( cosom < 0.0 ) {
			cosom = -cosom;
			bx = - bx;
			by = - by;
			bz = - bz;
			bw = - bw;
		}
		// calculate coefficients
		if ( (1.0 - cosom) > 0.000001 ) {
			// standard case (slerp)
			omega  = FastMath.acos(cosom);
			sinom  = FastMath.sin(omega);
			scale0 = FastMath.sin((1.0 - amount) * omega) / sinom;
			scale1 = FastMath.sin(amount * omega) / sinom;
		} else {
			// "from" and "to" quaternions are very close
			//  ... so we can do a linear interpolation
			scale0 = 1.0 - amount;
			scale1 = amount;
		}
		// calculate final values
		out[outIndex+0] = scale0 * ax + scale1 * bx;
		out[outIndex+1] = scale0 * ay + scale1 * by;
		out[outIndex+2] = scale0 * az + scale1 * bz;
		out[outIndex+3] = scale0 * aw + scale1 * bw;

		return out;
	}

	/**
		Calculates the inverse of a Quat at `index`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `QuatArray`
	 **/
	@:extern public inline function invert(index:Int, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return invert_impl(index, out, outIndex);
	}

	private function invert_impl(index:Int, out:QuatArray, outIndex:Int):QuatArray
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}
		index <<= 2; outIndex = outIndex << 2;
		var a0 = this[index+0], a1 = this[index+1], a2 = this[index+2], a3 = this[index+3];
		var dot = a0*a0 + a1*a1 + a2*a2 + a3*a3;
		if (dot == 0)
		{
			out[outIndex+0] = out[outIndex+1] = out[outIndex+2] = out[outIndex+3] = 0;
			return out;
		}
		var invDot = 1.0/dot;

		out[outIndex+0] = -a0*invDot;
		out[outIndex+1] = -a1*invDot;
		out[outIndex+2] = -a2*invDot;
		out[outIndex+3] = a3*invDot;
		return out;
	}

	/**
		Calculates the conjugate of a `Quat`
		If the quaternion is normalized, this function is faster than `inverse`
		and produces the same result
	 **/
	@:extern public inline function conjugate(index:Int, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return conjugate_impl(index, out, outIndex);
	}

	private function conjugate_impl(index:Int, out:QuatArray, outIndex:Int):QuatArray
	{
		if (out == null)
		{
			out = t();
			outIndex = index;
		}
		index <<= 2; outIndex = outIndex << 2;

		out[outIndex+0] = -this[index+0];
		out[outIndex+1] = -this[index+1];
		out[outIndex+2] = -this[index+2];
		out[outIndex+3] = this[index+3];
		return out;
	}

	/**
		Calculates the length of a `Quat` at `index`
	 **/
	@:extern inline public function lengthAt(index:Int):Float
	{
		return Vec4Array.lengthAt(cast this, index);
	}

	/**
		Calculates the squared length of a `Quat` at `index`
	 **/
	@:extern inline public function sqrlenAt(index:Int):Float
	{
		return Vec4Array.sqrlenAt(cast this, index);
	}

	/**
		Normalize a `Quat` at `index`
	 **/
	@:extern inline public function normalize(index:Int, ?out:QuatArray, outIndex:Int=-1):QuatArray
	{
		return untyped Vec4Array.normalize(this, index, cast out, outIndex);
	}

	private function normalize_internal(index:Int, out:QuatArray, outIndex:Int):QuatArray
	{
		Vec4Array.normalize_inline(this, index,cast out, outIndex);
		return out;
	}

	/**
		Creates a quaternion from the given 3x3 rotation matrix, and stores it on `this`,
		at position `index`

		NOTE: The resultant quaternion is not normalized, so you should be sure
		to renormalize the quaternion yourself where necessary
	 **/
	@:extern inline public function fromMat3(index:Int, m:Mat3Array, mIndex:Int):QuatArray
	{
		index <<= 2; mIndex *= 9;
		return fromMat3_internal(index, m[mIndex+0],m[mIndex+1],m[mIndex+2],m[mIndex+3],m[mIndex+4],m[mIndex+5],m[mIndex+6],m[mIndex+7],m[mIndex+8]);
	}

	/**
		Returns true if the quaternions are equal
	 **/
	@:extern inline public function eq(index:Int, b:QuatArray, bIndex:Int):Bool
	{
		return Vec4Array.eq(this,index,cast b, bIndex);
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
				buf.add(this[ (i << 2) + j ]);
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

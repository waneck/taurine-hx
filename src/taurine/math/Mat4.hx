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
	4x4 Matrix
 **/
	@:arrayAccess
abstract Mat4(SingleVector) //to Mat4Array
{
	public var a00(get,set):Single;
	public var a01(get,set):Single;
	public var a02(get,set):Single;
	public var a03(get,set):Single;
	public var a10(get,set):Single;
	public var a11(get,set):Single;
	public var a12(get,set):Single;
	public var a13(get,set):Single;
	public var a20(get,set):Single;
	public var a21(get,set):Single;
	public var a22(get,set):Single;
	public var a23(get,set):Single;
	public var a30(get,set):Single;
	public var a31(get,set):Single;
	public var a32(get,set):Single;
	public var a33(get,set):Single;

	/**
		Creates a new identity Mat4
	 **/
	@:extern public inline function new()
	{
		this = SingleVector.alloc(16);
		this[0] = this[5] = this[10] = this[15] = 1;
#if neko
		this[1] = this[2] = this[3] = this[4] =
			this[6] = this[7] = this[8] = this[9] =
			this[11] = this[12] = this[13] = this[14] = 0;
#end
	}

	/**
		Creates an empty Mat4
	 **/
	@:extern inline public static function mk():Mat4
	{
		return untyped SingleVector.alloc(16);
	}

	/**
		Tells whether this Mat4 has more than one Mat4 element
	 **/
	@:extern inline public function hasMultiple():Bool
	{
		return this.length > 16;
	}

	/**
		Returns the value of `this` Matrix, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function matval(row:Int, column:Int):Single
	{
		return this[(row << 2) + column];
	}

	/**
		Sets the value of `this` Matrix, located at `row` and `column`
		Does not perform bounds check
	 **/
	@:extern inline public function setMatval(row:Int, column:Int, v:Single):Single
	{
		return this[(row << 2) + column] = v;
	}

	/**
		Clones the current Mat4
	 **/
	public function clone():Mat4
	{
		var ret = mk();
		for (i in 0...16) ret[i] = this[i];
		return ret;
	}

	/**
		Copies `this` matrix to `dest`, and returns `dest`
	 **/
	public function copyTo(dest:Mat4):Mat4
	{
		for (i in 0...16)
			dest[i] = this[i];
		return dest;
	}

	@:extern private inline function t():Mat4 return untyped this; //get `this` as the abstract type

	/**
		Reinterpret `this` Matrix as an array (of length 1)
	 **/
	@:to @:extern inline public function array():Mat4Array
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Set the Mat4 at `index` to the identity matrix.

		Returns itself
	 **/
	public function identity():Mat4
	{
		this[0] = this[5] = this[10] = this[15] = 1;
		this[1] = this[2] = this[3] = this[4] =
			this[6] = this[7] = this[8] = this[9] =
			this[11] = this[12] = this[13] = this[14] = 0;
		return t();
	}

	/**
		Transpose the values of a Mat4 and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`
	 **/
	@:extern inline public function transpose(?out:Mat4):Mat4
	{
		return Mat4Array.transpose(this,0,out,0).first();
	}

	/**
		Inverts current matrix and stores the value at `out` matrix

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`; If the operation fails, returns `null`
	 **/
	@:extern inline public function invert(?out:Mat4):Mat4
	{
		return Mat4Array.invert(this, 0, out, 0).first();
	}

	/**
		Calculates the adjugate of a Mat4

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`;
	 **/
	@:extern inline public function adjoint(?out:Mat4):Mat4
	{
		return Mat4Array.adjoint(this,0,out,0).first();
	}

	/**
		Calculates de determinant of the Mat4
	 **/
	@:extern inline public function det():Float
	{
		return Mat4Array.det(this,0);
	}

	/**
		Multiplies current matrix with matrix `b`,
		and stores the value on `out` matrix

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`
	 **/
	@:extern inline public function mul(b:Mat4, ?out:Mat4):Mat4
	{
		return Mat4Array.mul(this, 0, b, 0, out, 0).first();
	}

	@:op(A*B) @:extern inline public static function opMult(a:Mat4, b:Mat4):Mat4
	{
		return Mat4Array.mul(a.getData(),0,b,0,mk(),0).first();
	}

	/**
		Translates the mat4 with `x`, `y` and `z`.

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`
	 **/
	@:extern inline public function translate(x:Single, y:Single, z:Single, ?out:Mat4):Mat4
	{
		return Mat4Array.translate(this,0,x,y,z,out).first();
	}

	/**
		Translates the mat4 with the `vec` Vec3
		@see Mat4#translate
	 **/
	@:extern inline public function translatev(vec:Vec3, ?out:Mat4):Mat4
	{
		return translate(vec[0],vec[1],vec[2],out);
	}

	/**
		Scales the mat4 by `x`, `y`, `z`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`
	 **/
	@:extern inline public function scale(x:Single, y:Single, z:Single, ?out:Mat4):Mat4
	{
		return Mat4Array.scale(this,0,x,y,z,out,0).first();
	}

	@:extern inline public function scalev(vec:Vec3, ?out:Mat4):Mat4
	{
		return scale(vec[0],vec[1],vec[2],out);
	}

	/**
		Rotates `this` matrix by the given angle at the (`x`, `y`, `z`) vector

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`
	 **/
	@:extern inline public function rotate(angle:Rad, x:Single, y:Single, z:Single, ?out:Mat4):Mat4
	{
		return Mat4Array.rotate(this,0,angle,x,y,z,out,0).first();
	}

	@:extern inline public function rotate_v(angle:Rad, vec:Vec3, ?out:Mat4):Mat4
	{
		return rotate(angle,vec[0],vec[1],vec[2],out);
	}

	/**
		Rotates `this` matrix by the given angle at the X axis

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`
	 **/
	@:extern inline public function rotateX(angle:Rad, ?out:Mat4):Mat4
	{
		return Mat4Array.rotateX(this,0,angle,out,0).first();
	}

	/**
		Rotates `this` matrix by the given angle at the Y axis

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Mat4`
	 **/
	@:extern inline public function rotateY(angle:Rad, ?out:Mat4):Mat4
	{
		return Mat4Array.rotateY(this,0,angle,out,0).first();
	}

	/**
		Rotates `this` matrix by the given angle at the Z axis

		If `out` is null, it will implicitly be considered itself;
		If `outIndex` is null, it will be considered to be the same as `index`.
		Returns the changed `Mat4`
	 **/
	@:extern inline public function rotateZ(angle:Rad, ?out:Mat4):Mat4
	{
		return Mat4Array.rotateZ(this,0,angle,out,0).first();
	}

	/**
		Calculates the matrix from the quaternion `quat` at `quatIndex`, and
		translation at `x`, `y` and `z`, and stores it on `this` matix

		Returns `this` matrix
	 **/
	@:extern inline public function fromQuatPos(quat:Quat, x:Single, y:Single, z:Single):Mat4
	{
		return Mat4Array.fromQuatPos(this,0,quat,0,x,y,z).first();
	}

	/**
		@see fromQuatPos
	 **/
	@:extern inline public function fromQuatPos_v(quat:Quat, vec:Vec3):Mat4
	{
		return fromQuatPos(quat,vec[0], vec[1], vec[2]);
	}

	/**
		Calculates a 4x4 matrix from the quaternion `quat` at `quatIndex`, and
		stores the result on `this` matrix

		Returns `this` matrix array
	 **/
	@:extern inline public function fromQuat(quat:Quat):Mat4
	{
		return Mat4Array.fromQuat(this,0,quat,0).first();
	}

	/**
		Generates a frustum matrix with the given bounds and writes on `this` array
	 **/
	@:extern inline public function frustum(left:Single, right:Single, bottom:Single, top:Single, near:Single, far:Single):Mat4
	{
		return Mat4Array.frustum(this,0,left,right,bottom,top,near,far).first();
	}

	/**
		Generates a perspective projection matrix with the given bounds and writes on `this` array

		`fovy` - Vertical field of view in radians
		`aspect` - Aspect ratio, typically viewport width / height
		`near` - Near bound of the frustum
		`far` - Far bound of the frustum
	 **/
	@:extern inline public function perspective(fovy:Rad, aspect:Single, near:Single, far:Single):Mat4
	{
		return Mat4Array.perspective(this,0,fovy,aspect,near,far).first();
	}

	@:extern inline public function persp(fovy:Rad, aspect:Single, near:Single, far:Single):Mat4
	{
		return perspective(fovy,aspect,near,far);
	}

	/**
		Generates an orthogonal matrix with the given bounds and writes on `this` mat array
	 **/
	@:extern inline public function ortho(left:Single, right:Single, bottom:Single, top:Single, near:Single, far:Single):Mat4
	{
		return Mat4Array.ortho(this,0,left,right,bottom,top,near,far).first();
	}

	/**
		Generates a look-at matrix, with the given `eye` position,
		focal point(`center`) and `up` axis
		`eye` - The position of the eye point (camera origin)
		`center` - The point to aim the camera at
		`up` - the vector that identifies the up direction for the camera

		Returns `this` Mat4
	 **/
	@:extern inline public function lookAt(eye:Vec3, center:Vec3, up:Vec3):Mat4
	{
		return Mat4Array.lookAt(this,0,eye,0,center,0,up).first();
	}

	/**
		Alias to lookAt
		@see lookAt
	 **/
	@:extern inline public function lookAtv(eye:Vec3, center:Vec3, up:Vec3):Mat4
	{
		return Mat4Array.lookAt(this,0,eye,0,center,0,up).first();
	}

	public function toString():String
	{
		var buf = new StringBuf();
		var support = [], maxn = 0;
		buf.add('mat4(');
		for (i in 0...16)
		{
			var s = support[ i ] = this[ i ] + "";
			if (s.length > maxn) maxn = s.length;
		}

		var fst = true;
		for (j in 0...4)
		{
			if (fst) fst = false; else buf.add('     ');
			for (k in 0...4)
			{
				buf.add(StringTools.rpad(support[ (j << 2) + k ], " ", maxn));
			}
		}
		buf.add(")");

		return buf.toString();
	}

	public function eq(b:Mat4):Bool
	{
		if (this == b.getData())
			return true;
		else if (this == null || b == null)
			return false;
		for (i in 0...16)
		{
			var v = this[i] - b[i];
			if (v != 0 && (v < 0 && v < -FastMath.EPSILON) || (v > FastMath.EPSILON)) //this != b
				return false;
		}
		return true;
	}

	@:op(A==B) @:extern inline public static function opEq(a:Mat4, b:Mat4):Bool
	{
		return a.eq(b);
	}

	@:op(A!=B) @:extern inline public static function opNEq(a:Mat4, b:Mat4):Bool
	{
		return !a.eq(b);
	}

	/**
		Transforms a Vec4 by a matrix
	 **/
	@:op(A*B) @:extern inline public static function opTransformVec(a:Mat4, b:Vec4):Vec4
	{
		return b.transformMat4(a,Vec4.mk());
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
	@:extern inline private function get_a03():Single return this[3];
	@:extern inline private function set_a03(val:Single):Single return this[3] = val;
	@:extern inline private function get_a10():Single return this[4];
	@:extern inline private function set_a10(val:Single):Single return this[4] = val;
	@:extern inline private function get_a11():Single return this[5];
	@:extern inline private function set_a11(val:Single):Single return this[5] = val;
	@:extern inline private function get_a12():Single return this[6];
	@:extern inline private function set_a12(val:Single):Single return this[6] = val;
	@:extern inline private function get_a13():Single return this[7];
	@:extern inline private function set_a13(val:Single):Single return this[7] = val;
	@:extern inline private function get_a20():Single return this[8];
	@:extern inline private function set_a20(val:Single):Single return this[8] = val;
	@:extern inline private function get_a21():Single return this[9];
	@:extern inline private function set_a21(val:Single):Single return this[9] = val;
	@:extern inline private function get_a22():Single return this[10];
	@:extern inline private function set_a22(val:Single):Single return this[10] = val;
	@:extern inline private function get_a23():Single return this[11];
	@:extern inline private function set_a23(val:Single):Single return this[11] = val;
	@:extern inline private function get_a30():Single return this[12];
	@:extern inline private function set_a30(val:Single):Single return this[12] = val;
	@:extern inline private function get_a31():Single return this[13];
	@:extern inline private function set_a31(val:Single):Single return this[13] = val;
	@:extern inline private function get_a32():Single return this[14];
	@:extern inline private function set_a32(val:Single):Single return this[14] = val;
	@:extern inline private function get_a33():Single return this[15];
	@:extern inline private function set_a33(val:Single):Single return this[15] = val;
}

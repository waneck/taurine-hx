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
	@:arrayAccess
abstract Quat(SingleVector)// to QuatArray
{
	public var x(get,set):Single;
	public var y(get,set):Single;
	public var z(get,set):Single;
	public var w(get,set):Single;

	/**
		Creates a new Quat
	 **/
	@:extern public inline function new(x=0.,y=0.,z=0.,w=1.)
	{
		this = SingleVector.alloc(4);
		this[0] = x; this[1] = y; this[2] = z; this[3] = w;
	}

	/**
		Creates an empty Quat
	 **/
	@:extern inline public static function mk():Quat
	{
		return untyped SingleVector.alloc(4);
	}

	/**
		Tells whether this Quat has more than one Quat element
	 **/
	@:extern inline public function hasMultiple():Bool
	{
		return this.length > 4;
	}

	@:extern private inline function t():Quat return untyped this; //get `this` as the abstract type

	/**
		Clones `this` Quat
	 **/
	@:extern inline public function clone():Quat
	{
		return untyped Vec4.clone(this);
	}

	/**
		Copies `this` Quat to `dest`, and returns `dest`
	 **/
	@:extern inline public function copyTo(dest:Quat):Quat
	{
		return untyped Vec4.copyTo(this,untyped dest);
	}

	/**
		Reinterpret `this` array as an array (of length 1)
	 **/
	@:to @:extern inline public function array():QuatArray
	{
		return untyped this;
	}

	@:extern public inline function getData():SingleVector
	{
		return this;
	}

	/**
		Sets the components of `this` Quat
		Returns itself
	 **/
	public function set(x:Single, y:Single, z:Single, w:Single):Quat
	{
		this[0] = x;
		this[1] = y;
		this[2] = z;
		this[3] = w;
		return t();
	}

	/**
		Sets a Quaternion to represent the shortes rotation from one Vec3 to another

		Both vectors are assumed to be unit length

		`a` - The initial vector
		`b` - The destination vector
		Returns itself
	 **/
	@:extern inline public function rotationTo(ax:Single,ay:Single,az:Single, bx:Single,by:Single,bz:Single):Quat
	{
		return QuatArray.rotationTo(this,0, ax,ay,az, bx,by,bz).first();
	}

	/**
		@see rotationTo
 	**/
	@:extern inline public function rotationTov(a:Vec3, b:Vec3):Quat
	{
		return QuatArray.rotationTov(this,0,a,0,b,0).first();
	}

	/**
		Set the specified quaternion with values corresponding to the given
		axes. Each axis is a `Vec3` and is expected to be unit length and
		perpendicular to all other specified axes.

		`view` - The vector representing the viewing direction
		`right` - The vector representing the local `right` direction
		`up` - The vector representing the local `up` direction
	 **/
	@:extern inline public function setAxes(view:Vec3, right:Vec3, up:Vec3):Quat
	{
		return QuatArray.setAxes(this,0,view,0,right,0,up,0).first();
	}

	/**
		Set the Quat to the identity quaternion.

		Returns itself
	 **/
	@:extern inline public function identity():Quat
	{
		return QuatArray.identity(this,0).first();
	}

	/**
		Sets a Quat from the given angle (`rad`) and rotation `axis`

		`axis` - The axis around which to rotate
		`rad` - The angle in radians
		Returns itself
	 **/
	@:extern inline public function setAxisAngle(axisX:Single, axisY:Single, axisZ:Single, rad:Rad):Quat
	{
		return QuatArray.setAxisAngle(this,0,axisX,axisY,axisZ,rad).first();
	}

	@:extern inline public function setAxisAngle_v(index:Int, axis:Vec3, rad:Rad):QuatArray
	{
		return setAxisAngle(axis[0],axis[1],axis[2],rad);
	}

	/**
		Adds `this` Quat to `b`, and stores the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Quat`
	 **/
	@:extern inline public function add(b:Quat, ?out:Quat):Quat
	{
		return cast Vec4Array.add(this, 0, cast b, 0, cast out, 0);
	}

	@:op(A+B) @:extern inline public static function opAdd(a:Quat, b:Quat):Quat
	{
		return a.add(b,mk());
	}

	/**
		Multiplies `this` Quat with `b`, and store the result at `out`

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Quat`
	 **/
	@:extern inline public function mul(b:Quat, ?out:Quat):Quat
	{
		return QuatArray.mul(this,0,b,0,out,0).first();
	}

	@:op(A*B) @:extern inline public static function opMul(a:Quat, b:Quat):Quat
	{
		return a.mul(b,mk());
	}

	/**
		Scales a Quat by a scalar number

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Quat`
	 **/
	@:extern inline public function scale(scalar:Single, ?out:Quat):Quat
	{
		return QuatArray.scale(this,0,scalar,out,0).first();
	}

	@:op(A*B) @:extern inline public static function opMulScalar(a:Quat, b:Single):Quat
	{
		return a.scale(b,mk());
	}

	@:op(A*B) @:extern inline public static function opMulScalar_1(b:Single, a:Quat):Quat
	{
		return a.scale(b,mk());
	}

	/**
		Rotates a quaternion by the given angle about the x axis
	 **/
	@:extern inline public function rotateX(rad:Rad, ?out:Quat):Quat
	{
		return QuatArray.rotateX(this,0,rad,out,0).first();
	}

	/**
		Rotates a quaternion by the given angle about the y axis
	 **/
	@:extern inline public function rotateY(rad:Rad, ?out:Quat):Quat
	{
		return QuatArray.rotateY(this,0,rad,out,0).first();
	}

	/**
		Rotates a quaternion by the given angle about the z axis
	 **/
	@:extern inline public function rotateZ(rad:Rad, ?out:Quat):Quat
	{
		return QuatArray.rotateZ(this,0,rad,out,0).first();
	}

	/**
		Calculates the w component of a Quat from the x,y and z components.
		Assumes that a quaternion is 1 unit in length
		Any existing W component will be ignored
		Modifies the value in-place and returns it
	 **/
	@:extern inline public function calculateW():Quat
	{
		return QuatArray.calculateW(this,0).first();
	}

	/**
		Calculates the dot product of two quat's
	 **/
	@:extern inline public function dot(b:Quat):Float
	{
		return QuatArray.dot(this, 0, b, 0);
	}

	/**
		Performs a linear interpolation between two quat's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Quat`
	 **/
	@:extern inline public function lerp(to:Quat, t:Float, ?out:Quat):Quat
	{
		return QuatArray.lerp(this,0,to,0,t,out,0).first();
	}

	/**
		Performs a spherical linear interpolation between two quat's

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Quat`
	 **/
	@:extern inline public function slerp(to:Quat, t:Float, ?out:Quat):Quat
	{
		return QuatArray.slerp(this,0,to,0,t,out,0).first();
	}

	/**
		Calculates the inverse of a Quat

		If `out` is null, it will implicitly be considered itself;
		Returns the changed `Quat`
	 **/
	@:extern inline public function invert(?out:Quat):Quat
	{
		return QuatArray.invert(this,0,out,0).first();
	}

	/**
		Calculates the conjugate of a `Quat`
		If the quaternion is normalized, this function is faster than `inverse`
		and produces the same result
	 **/
	@:extern inline public function conjugate(?out:Quat):Quat
	{
		return QuatArray.conjugate(this,0,out,0).first();
	}

	/**
		Calculates the length of a `Quat`
	 **/
	@:extern inline public function length():Float
	{
		return QuatArray.lengthAt(this,0);
	}

	/**
		Calculates the squared length of a `Quat`
	 **/
	@:extern inline public function sqrlen():Float
	{
		return QuatArray.sqrlenAt(this,0);
	}

	/**
		Normalize a `Quat`
	 **/
	@:extern inline public function normalize(?out:Quat):Quat
	{
		return QuatArray.normalize(this,0,out,0).first();
	}

	/**
		Creates a quaternion from the given 3x3 rotation matrix, and stores it on `this`

		NOTE: The resultant quaternion is not normalized, so you should be sure
		to renormalize the quaternion yourself where necessary
	 **/
	@:extern inline public function fromMat3(m:Mat3):Quat
	{
		return QuatArray.fromMat3(this,0,m,0).first();
	}

	/**
		Returns true if the quaternions are equal
	 **/
	@:extern inline public function eq(b:Quat):Bool
	{
		return Vec4.eq(this,untyped b);
	}

	@:op(A==B) @:extern inline public static function opEq(a:Quat, b:Quat):Bool
	{
		return a.eq(b);
	}

	@:op(A!=B) @:extern inline public static function opNEq(a:Quat, b:Quat):Bool
	{
		return !a.eq(b);
	}

	/**
		Rotates the point `b` with `a`
	 **/
	@:op(A*B) @:extern inline public static function opTransformVec(a:Quat, b:Vec3):Vec3
	{
		return b.transformQuat(a, Vec3.mk());
	}

	public function toString():String
	{
		var buf = new StringBuf();
		{
			buf.add('quat(');
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

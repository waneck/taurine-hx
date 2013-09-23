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
		Creates a new Mat4Array with the given size
	**/
	public inline function new(len:Int)
	{
		this = SingleVector.alloc(len << 4);
	}

	/**
		The number of Mat4 elements contained in this array
	**/
	public var length(get,never):Int;

	private inline function get_length():Int
	{
		return this.length >>> 4;
	}

	private inline function t():Mat4Array return untyped this; //get `this` as the abstract type

	public inline function getData():SingleVector
	{
		return this;
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
			If `outIndex` is null, it will be considered to be the same as `index`
			Returns the changed `Mat4Array`
	**/
	public function transpose(index:Int, ?outIndex:Int, ?out:Mat4Array)
	{

	}

	@:extern inline private function transpose_inline_same(index:Int)
	{

	}

	@:extern inline private function transpose_inline_diff(index:Int, outIndex:Int, out:Mat4Array)
	{
	}
}

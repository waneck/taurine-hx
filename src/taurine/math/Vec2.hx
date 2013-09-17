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
abstract Vec2(Vector<Single>)
{
	/**
		Creates a new Vec2
	**/
	public inline function new(x = 0, y = 0)
	{
		this = VectorTools.create(2);
		this[0] = x; this[1] = y;
	}

	public static inline function mk():Vec2
	{
		return untyped (VectorTools.create(2) : Vector<Single>);
	}

	/**
		Creates a new Vec2 initialized with values from `this` vector
	**/
	public function clone():Vec2
	{
		var out = mk();
		out[0] = this[0];
		out[1] = this[1];
		return out;
	}

	/**
		Copy the value from one Vec2 to another. The parameter `out` cannot be null.
	**/
	public function copy(out:Vec2):Vec2
	{
		out[0] = this[0];
		out[1] = this[1];
		return out;
	}

	/**
		Set the components of a Vec2 to the given values
	**/
	public function set(x:Single, y:Single):Vec2
	{
		this[0] = x;
		this[1] = y;
		return untyped this;
	}



}

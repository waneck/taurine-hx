package taurine.tests.mem;
import taurine.mem.RawMem;
import utest.Assert;

class RawMemTests
{

	public function new()
	{
	}
	//tests from https://github.com/inexorabletash/polyfill/blob/master/tests/typedarray_tests.js
	//Copyright (C) 2010 Linden Research, Inc. Originally published at: https://bitbucket.org/lindenlab/llsd/
	private function stricterEqual(actual:Float, expected:Float, message:String, ?pos:haxe.PosInfos)
	{
		message = '($message) Expected $expected. Got $actual';
		if (Math.isNaN(expected))
		{
			Assert.isTrue(Math.isNaN(actual) && Math.isFinite(expected) == Math.isFinite(actual) && (actual > 0) == (expected > 0), message, pos);
		} else {
			Assert.floatEquals(expected, actual, message, pos);
		}
	}

	public function test_Single_unpack()
	{
		function fromBytes(arr:Array<Int>):Float
		{
			var ret = RawMem.alloc(arr.length);
			for (i in 0...arr.length)
				ret.setUInt8(i,arr[i]);
			return ret.getFloat32(0);
		}
		stricterEqual(fromBytes([0xff, 0xff, 0xff, 0xff]), Math.NaN, 'Q-NaN');
		stricterEqual(fromBytes([0xff, 0xc0, 0x00, 0x01]), Math.NaN, 'Q-NaN');

		stricterEqual(fromBytes([0xff, 0xc0, 0x00, 0x00]), Math.NaN, 'Indeterminate');

		stricterEqual(fromBytes([0xff, 0xbf, 0xff, 0xff]), Math.NaN, 'S-NaN');
		stricterEqual(fromBytes([0xff, 0x80, 0x00, 0x01]), Math.NaN, 'S-NaN');

		stricterEqual(fromBytes([0xff, 0x80, 0x00, 0x00]), Math.NEGATIVE_INFINITY, '-Infinity');

		stricterEqual(fromBytes([0xff, 0x7f, 0xff, 0xff]), -3.4028234663852886E+38, '-Normalized');
		stricterEqual(fromBytes([0x80, 0x80, 0x00, 0x00]), -1.1754943508222875E-38, '-Normalized');
		stricterEqual(fromBytes([0xff, 0x7f, 0xff, 0xff]), -3.4028234663852886E+38, '-Normalized');
		stricterEqual(fromBytes([0x80, 0x80, 0x00, 0x00]), -1.1754943508222875E-38, '-Normalized');

		// TODO: Denormalized values fail on Safari on iOS/ARM
		stricterEqual(fromBytes([0x80, 0x7f, 0xff, 0xff]), -1.1754942106924411E-38, '-Denormalized');
		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x01]), -1.4012984643248170E-45, '-Denormalized');

		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x00]), 0, '-0');
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x00]), 0, '+0');

		// TODO: Denormalized values fail on Safari on iOS/ARM
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x01]), 1.4012984643248170E-45, '+Denormalized');
		stricterEqual(fromBytes([0x00, 0x7f, 0xff, 0xff]), 1.1754942106924411E-38, '+Denormalized');

		stricterEqual(fromBytes([0x00, 0x80, 0x00, 0x00]), 1.1754943508222875E-38, '+Normalized');
		stricterEqual(fromBytes([0x7f, 0x7f, 0xff, 0xff]), 3.4028234663852886E+38, '+Normalized');

		stricterEqual(fromBytes([0x7f, 0x80, 0x00, 0x00]), Math.POSITIVE_INFINITY, '+Infinity');

		stricterEqual(fromBytes([0x7f, 0x80, 0x00, 0x01]), Math.NaN, 'S+NaN');
		stricterEqual(fromBytes([0x7f, 0xbf, 0xff, 0xff]), Math.NaN, 'S+NaN');

		stricterEqual(fromBytes([0x7f, 0xc0, 0x00, 0x00]), Math.NaN, 'Q+NaN');
		stricterEqual(fromBytes([0x7f, 0xff, 0xff, 0xff]), Math.NaN, 'Q+NaN');
	}

	public function test_Single_pack()
	{

	}

}

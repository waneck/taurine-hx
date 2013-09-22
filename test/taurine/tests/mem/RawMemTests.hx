package taurine.tests.mem;
import taurine.mem.RawMem;
import utest.Assert;

class RawMemTests
{
	public function new()
	{
	}

	private function alloc(len:Int):RawMem
	{
		return RawMem.alloc(len);
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

	private function ui8equal(mem:RawMem, arr:Array<Int>, ?msg:String, ?pos:haxe.PosInfos)
	{
		if (msg == null) msg = "";
		for (i in 0...arr.length)
		{
			var msg = '($msg) Expected ${arr[i]}; got ${mem.getUInt8(i)} for index $i - $arr';
			Assert.equals(arr[i], mem.getUInt8(i), msg, pos);
		}
		var msg = '($msg) Length mismatch: Expected ${arr.length}; got ${mem.byteLength}.';
		Assert.equals(arr.length, mem.byteLength, msg, pos);
	}

	public function test_conversions()
	{
		var arr = alloc(4);
		arr.setUInt8(0,1);
		arr.setUInt8(1,2);
		arr.setUInt8(2,3);
		arr.setUInt8(3,4);

		ui8equal(arr, [1,2,3,4]);
		arr.setUInt16(0,0xFFFF);
		ui8equal(arr, [0xff,0xff,3,4]);
		arr.setUInt16(2,0xEEEE);
		ui8equal(arr, [0xff,0xff,0xee,0xee]);
		arr.setInt32(0,0x11111111);
		Assert.equals(arr.getUInt16(0), 0x1111);
		Assert.equals(arr.getUInt16(2), 0x1111);
		ui8equal(arr, [0x11,0x11,0x11,0x11]);
	}

	public function test_signed_unsigned()
	{
		var mem = alloc(4);
		mem.setUInt8(0,123);
		Assert.equals(123, mem.getUInt8(0));
		mem.setUInt8(0,161);
		Assert.equals(161, mem.getUInt8(0));
		mem.setUInt8(0,-120);
		Assert.equals(136, mem.getUInt8(0));
		mem.setUInt8(0,-1);
		Assert.equals(0xff, mem.getUInt8(0));

		mem.setUInt16(0,3210);
		Assert.equals(3210, mem.getUInt16(0));
		mem.setUInt16(0,49232);
		Assert.equals(49232, mem.getUInt16(0));
		mem.setUInt16(0,-16384);
		Assert.equals(49152, mem.getUInt16(0));
		mem.setUInt16(0,-1);
		Assert.equals(0xFFFF, mem.getUInt16(0));
	}

	public function test_float32_unpack()
	{
		var littleEndian = alloc(2).isLittleEndian();
		function fromBytes(arr:Array<Int>):Float
		{
			var ret = alloc(arr.length);
			if (!littleEndian)
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[i]);
			else
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[3-i]);
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

	public function test_float32_pack()
	{
		var littleEndian = alloc(2).isLittleEndian();
		function toBytes(v:Float):RawMem
		{
			var ret = alloc(4);
			ret.setFloat32(0,v);
			return ret;
		}
		var ui8equal = littleEndian ? function(b:RawMem, arr:Array<Int>, str:String, ?pos:haxe.PosInfos)
		{
			arr.reverse();
			return ui8equal(b,arr,str,pos);
		} : ui8equal;

		ui8equal(toBytes(Math.NEGATIVE_INFINITY), [0xff, 0x80, 0x00, 0x00], '-Infinity');

		ui8equal(toBytes(-3.4028235677973366e+38), [0xff, 0x80, 0x00, 0x00], '-Overflow');
		ui8equal(toBytes(-3.402824E+38), [0xff, 0x80, 0x00, 0x00], '-Overflow');

		ui8equal(toBytes(-3.4028234663852886E+38), [0xff, 0x7f, 0xff, 0xff], '-Normalized');
		ui8equal(toBytes(-1.1754943508222875E-38), [0x80, 0x80, 0x00, 0x00], '-Normalized');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(-1.1754942106924411E-38), [0x80, 0x7f, 0xff, 0xff], '-Denormalized');
		ui8equal(toBytes(-1.4012984643248170E-45), [0x80, 0x00, 0x00, 0x01], '-Denormalized');

		ui8equal(toBytes(-7.006492321624085e-46), [0x80, 0x00, 0x00, 0x00], '-Underflow');

		// unsupported -0
		// ui8equal(toBytes(-0), [0x80, 0x00, 0x00, 0x00], '-0');
		ui8equal(toBytes(0), [0x00, 0x00, 0x00, 0x00], '+0');

		ui8equal(toBytes(7.006492321624085e-46), [0x00, 0x00, 0x00, 0x00], '+Underflow');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(1.4012984643248170E-45), [0x00, 0x00, 0x00, 0x01], '+Denormalized');
		ui8equal(toBytes(1.1754942106924411E-38), [0x00, 0x7f, 0xff, 0xff], '+Denormalized');

		ui8equal(toBytes(1.1754943508222875E-38), [0x00, 0x80, 0x00, 0x00], '+Normalized');
		ui8equal(toBytes(3.4028234663852886E+38), [0x7f, 0x7f, 0xff, 0xff], '+Normalized');

		ui8equal(toBytes(3.402824E+38), [0x7f, 0x80, 0x00, 0x00], '+Overflow');
		ui8equal(toBytes(3.402824E+38), [0x7f, 0x80, 0x00, 0x00], '+Overflow');
		ui8equal(toBytes(Math.POSITIVE_INFINITY), [0x7f, 0x80, 0x00, 0x00], '+Infinity');

		// Allow any NaN pattern (exponent all 1's, fraction non-zero)
		// var nanbytes = toBytes(Math.NaN),
		// 		sign = extractbits(nanbytes, 31, 31),
		// 		exponent = extractbits(nanbytes, 23, 30),
		// 		fraction = extractbits(nanbytes, 0, 22);
		// ok(exponent === 255 && fraction !== 0, 'NaN');
	}

	public function test_float64_unpack()
	{
		var littleEndian = alloc(2).isLittleEndian();
		function fromBytes(arr:Array<Int>):Float
		{
			var ret = alloc(arr.length);
			if (!littleEndian)
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[i]);
			else
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[7-i]);
			return ret.getFloat64(0);
		}

		stricterEqual(fromBytes([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'Q-NaN');
		stricterEqual(fromBytes([0xff, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), Math.NaN, 'Q-NaN');

		stricterEqual(fromBytes([0xff, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.NaN, 'Indeterminate');

		stricterEqual(fromBytes([0xff, 0xf7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'S-NaN');
		stricterEqual(fromBytes([0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), Math.NaN, 'S-NaN');

		stricterEqual(fromBytes([0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.NEGATIVE_INFINITY, '-Infinity');

		stricterEqual(fromBytes([0xff, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), -1.7976931348623157E+308, '-Normalized');
		stricterEqual(fromBytes([0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), -2.2250738585072014E-308, '-Normalized');

		// TODO: Denormalized values fail on Safari iOS/ARM
		stricterEqual(fromBytes([0x80, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), -2.2250738585072010E-308, '-Denormalized');
		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), -4.9406564584124654E-324, '-Denormalized');

		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), -0, '-0');
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 0, '+0');

		// TODO: Denormalized values fail on Safari iOS/ARM
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), 4.9406564584124654E-324, '+Denormalized');
		stricterEqual(fromBytes([0x00, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), 2.2250738585072010E-308, '+Denormalized');

		stricterEqual(fromBytes([0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 2.2250738585072014E-308, '+Normalized');
		stricterEqual(fromBytes([0x7f, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), 1.7976931348623157E+308, '+Normalized');

		stricterEqual(fromBytes([0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.POSITIVE_INFINITY, '+Infinity');

		stricterEqual(fromBytes([0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), Math.NaN, 'S+NaN');
		stricterEqual(fromBytes([0x7f, 0xf7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'S+NaN');

		stricterEqual(fromBytes([0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.NaN, 'Q+NaN');
		stricterEqual(fromBytes([0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'Q+NaN');
	}

	public function test_float64_pack()
	{
		var littleEndian = alloc(2).isLittleEndian();
		function toBytes(v:Float):RawMem
		{
			var ret = alloc(8);
			ret.setFloat64(0,v);
			return ret;
		}
		var ui8equal = littleEndian ? function(b:RawMem, arr:Array<Int>, str:String, ?pos:haxe.PosInfos)
		{
			arr.reverse();
			return ui8equal(b,arr,str,pos);
		} : ui8equal;

		ui8equal(toBytes(Math.NEGATIVE_INFINITY), [0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '-Infinity');

		ui8equal(toBytes(-1.7976931348623157E+308), [0xff, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '-Normalized');
		ui8equal(toBytes(-2.2250738585072014E-308), [0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '-Normalized');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(-2.2250738585072010E-308), [0x80, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '-Denormalized');
		ui8equal(toBytes(-4.9406564584124654E-324), [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01], '-Denormalized');

		// unsupported -0
		// ui8equal(toBytes(-0), [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '-0');
		ui8equal(toBytes(0), [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '+0');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(4.9406564584124654E-324), [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01], '+Denormalized');
		ui8equal(toBytes(2.2250738585072010E-308), [0x00, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '+Denormalized');

		ui8equal(toBytes(2.2250738585072014E-308), [0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '+Normalized');
		ui8equal(toBytes(1.7976931348623157E+308), [0x7f, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '+Normalized');

		ui8equal(toBytes(Math.POSITIVE_INFINITY), [0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '+Infinity');
	}

	public function test_int32_roundtrips()
	{
		var mem = alloc(4);
		var data = [
			0,
			1,
			-1,
			123,
			-456,
			0x80000000,
			0x7fffffff,
			0x12345678,
			0x87654321
		];

		for (d in data)
		{
			mem.setInt32(0,d);
			Assert.equals(mem.getInt32(0), d);
		}
	}

	public function test_int16_roundtrips()
	{
		var mem = alloc(2);
		var data = [
			0,
			1,
				-1,
			123,
				-456,
			0xffff8000,
			0x00007fff,
			0x00001234,
			0xffff8765
		];

		for (d in data)
		{
			mem.setUInt16(0,d);
			if (d < 0)
				Assert.equals(mem.getUInt16(0), d & 0xFFFF);
			else
				Assert.equals(mem.getUInt16(0), d);
		}
	}

	public function test_int8_roundtrips()
	{
		var mem = alloc(1);
		var data = [
			0,
			1,
				-1,
			123,
				-45,
			0xffffff80,
			0x0000007f,
			0x00000012,
			0xffffff87
		];

		for (d in data)
		{
			mem.setUInt8(0,d);
			if (d < 0)
				Assert.equals(mem.getUInt8(0), d & 0xFF);
			else
				Assert.equals(mem.getUInt8(0), d);
		}
	}

	static inline var LN2 = taurine.math.MacroMath.reduce(Math.log(2));

	public function test_float32_roundtrips()
	{
		var mem = alloc(4);
		var data = [
			0,
			1,
				-1,
			123,
				-456,

			1.2,
			1.23,
			1.234,

			1.234e-30,
			1.234e-20,
			1.234e-10,
			1.234e10,
			1.234e20,
			1.234e30,

			3.1415,
			6.0221415e+23,
			6.6260693e-34,
			6.67428e-11,
			299792458,

			0,
				-0,
			Math.POSITIVE_INFINITY,
			Math.NEGATIVE_INFINITY,
			Math.NaN
		];

		//Round p to n binary places of binary
		function precision(n,p) {
			if (p >= 52 || Math.isNaN(n) || n == 0 || !Math.isFinite(n))
			{
				return n;
			} else {
				var m = Math.pow(2, p - Math.floor(Math.log(n) / LN2));
				return Math.round(n * m) / m;
			}
		}

		inline function single(n) return precision(n,23);

		for (d in data)
		{
			mem.setFloat32(0,d);
			stricterEqual(single(mem.getFloat32(0)), single(d), d +"");
		}
	}

	public function test_float64_roundtrips()
	{
		var mem = alloc(8);
		var data = [
			0,
			1,
			-1,
			123,
			-456,

			1.2,
			1.23,
			1.234,

			1.234e-30,
			1.234e-20,
			1.234e-10,
			1.234e10,
			1.234e20,
			1.234e30,

			3.1415,
			6.0221415e+23,
			6.6260693e-34,
			6.67428e-11,
			299792458,

			0,
			-0,
			Math.POSITIVE_INFINITY,
			Math.NEGATIVE_INFINITY,
			Math.NaN
		];

		for (d in data)
		{
			mem.setFloat64(0,d);
			stricterEqual(d, mem.getFloat64(0), d + "");
		}
	}

	public function test_accessors()
	{
		var mem = alloc(8);
		if (mem.isLittleEndian())
		{
			ui8equal(mem, [0,0,0,0,0,0,0,0]);
			mem.setUInt8(0, 255);
			ui8equal(mem, [0xff, 0, 0, 0, 0, 0, 0, 0]);

			mem.setUInt8(1, -1);
			ui8equal(mem, [0xff, 0xff, 0, 0, 0, 0, 0, 0]);

			mem.setUInt16(2, 0x1234);
			ui8equal(mem, [0xff, 0xff, 0x34, 0x12, 0, 0, 0, 0]);

			mem.setUInt16(4, -1);
			ui8equal(mem, [0xff, 0xff, 0x34, 0x12, 0xff, 0xff, 0, 0]);

			mem.setInt32(1, 0x12345678);
			ui8equal(mem, [0xff, 0x78, 0x56, 0x34, 0x12, 0xff, 0, 0]);

			mem.setInt32(4, -2023406815);
			ui8equal(mem, [0xff, 0x78, 0x56, 0x34, 0x21, 0x43, 0x65, 0x87]);

			mem.setFloat32(0, 1.2E+38);
			ui8equal(mem, [0x52, 0x8e, 0xb4, 126, 0x21, 0x43, 0x65, 0x87]);

			mem.setFloat64(0, -1.2345678E+301);
			var ret = [0xfe, 0x72, 0x6f, 0x51, 0x5f, 0x61, 0x77, 0xe5];
			ret.reverse();
			ui8equal(mem, ret);

			for (i in 0...8)
				mem.setUInt8(i, 0x80 + i);
			//0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87
			Assert.equals(mem.getUInt8(0), 128);
			Assert.equals(mem.getUInt8(1), -127 & 0xFF);
			Assert.equals(mem.getUInt16(2), 33666);
			Assert.equals(mem.getUInt16(3), 33923);
			Assert.equals(mem.getUInt16(4), 34180);
			Assert.equals(mem.getInt32(4), -2021227132);
			Assert.equals(mem.getInt32(2), -2054913150);
			stricterEqual(mem.getFloat32(2), -1.932478247535851e-37, "");
			stricterEqual(mem.getFloat64(0), -3.116851295377095e-306, "");
		} else {
			ui8equal(mem, [0,0,0,0,0,0,0,0]);
			mem.setUInt8(0, 255);
			ui8equal(mem, [0xff, 0, 0, 0, 0, 0, 0, 0]);

			mem.setUInt8(1, -1);
			ui8equal(mem, [0xff, 0xff, 0, 0, 0, 0, 0, 0]);

			mem.setUInt16(2, 0x1234);
			ui8equal(mem, [0xff, 0xff, 0x12, 0x34, 0, 0, 0, 0]);

			mem.setUInt16(4, -1);
			ui8equal(mem, [0xff, 0xff, 0x12, 0x34, 0xff, 0xff, 0, 0]);

			mem.setInt32(1, 0x12345678);
			ui8equal(mem, [0xff, 0x12, 0x34, 0x56, 0x78, 0xff, 0, 0]);

			mem.setInt32(4, -2023406815);
			ui8equal(mem, [0xff, 0x12, 0x34, 0x56, 0x87, 0x65, 0x43, 0x21]);

			mem.setFloat32(2, 1.2E+38);
			ui8equal(mem, [0xff, 0x12, 0x7e, 0xb4, 0x8e, 0x52, 0x43, 0x21]);

			mem.setFloat64(0, -1.2345678E+301);
			ui8equal(mem, [0xfe, 0x72, 0x6f, 0x51, 0x5f, 0x61, 0x77, 0xe5]);

			for (i in 0...8)
				mem.setUInt8(i, 0x80 + i);
			Assert.equals(mem.getUInt8(0), 128);
			Assert.equals(mem.getUInt8(1), -127 & 0xFF);
			Assert.equals(mem.getUInt16(2), 33411);
			Assert.equals(mem.getUInt16(3), -31868 & 0xFFFF);
			Assert.equals(mem.getInt32(4), -2071624057);
			Assert.equals(mem.getInt32(2), -2105310075);
			// no unaligned access
			// stricterEqual(mem.getFloat32(2), -1.932478247535851e-37, "");
			stricterEqual(mem.getFloat64(0), -3.116851295377095e-306, "");
		}
	}

}

class RawMemTestsBackwards extends RawMemTests
{
#if js
	override private function alloc(len:Int):RawMem
	{
		taurine.mem._internal.js.RawMemCompat.FORCE_ARRAY = false;
		return cast taurine.mem._internal.js.RawMemCompat.allocCompat(len);
	}
#end
}

class RawMemTestsArray extends RawMemTests
{
#if js
	override private function alloc(len:Int):RawMem
	{
		taurine.mem._internal.js.RawMemCompat.FORCE_ARRAY = true;
		return cast taurine.mem._internal.js.RawMemCompat.allocCompat(len);
	}
#end
}

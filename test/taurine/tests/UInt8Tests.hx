package taurine.tests;
import taurine.UInt8;
import utest.Assert;

//FIXME: cover all operations and overflow test
class UInt8Tests {

	public function new() {

	}

	public function testUnsigned()
	{
		var i = new UInt8(127);
		Assert.equals(127, i.toInt());
		i++;
		Assert.equals(128, i.toInt());
		i++;
		Assert.equals(129, i.toInt());
		Assert.equals(i.toString(), "129");

		var j = i << 1;
		Assert.equals(2, j);

		Assert.isTrue(i > 0);
		Assert.isTrue(j > 0);

		i--; i--;
		i *= 2;
		Assert.isTrue(i > 0);

		i = new UInt8(255);
		Assert.isTrue(i > 0);
		Assert.equals(255, i.toInt());

		i = i / 1;
		Assert.isTrue(i > 0);
		Assert.equals(255, i.toInt());
		i = (i - 1) % i;
		Assert.isTrue(i > 0);
		Assert.equals(254, i.toInt());
	}

}

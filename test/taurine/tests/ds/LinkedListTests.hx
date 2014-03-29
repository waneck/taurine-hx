package taurine.tests.ds;

import taurine.ds.LinkedList;
import taurine.ds.LinkedList.*;
import utest.Assert;

class LinkedListTests
{
	public function new()
	{
	}

	public function testCreate()
	{
		var lst = empty();
		Assert.isTrue(lst.isEmpty());
		Assert.equals(0,lst.count());
		Assert.equals(null,lst);
		lst = null;
		Assert.isTrue(lst.isEmpty());
		Assert.equals(0,lst.count());

		lst = 1 + lst;
		Assert.isFalse(lst.isEmpty());
		Assert.equals(1,lst.count());

		lst = 2 + lst;
		Assert.equals(2, lst.count());
		Assert.isTrue( lst == list(2,1) );
		Assert.isFalse( lst == list(1,2) );

		Assert.equals(empty(), list());
	}

	public function testMatch()
	{
		var x = list(1);
		var hasRun = false;
		list(1,2,3,4).match(switch _
		{
			case 1 + lst:
				hasRun = true;
				Assert.isTrue(lst == list(2,3,4));
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;
		list(1,2,3,4).match(switch _
		{
			case 1 + (2 + lst):
				hasRun = true;
				Assert.isTrue(lst == list(3,4));
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;
		list(1,2,3,4).match(switch _
		{
			case 1 + (2 + (3 + lst)):
				hasRun = true;
				Assert.isTrue(lst == list(4));
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;
		list(1,2,3,4).match(switch _
		{
			case 1 + list(2,3,4):
				hasRun = true;
				Assert.isTrue(true);
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;

		Assert.isTrue(list(1,2,3).matches(1 + (2 + _)));
		Assert.isFalse(list(1,2,3).matches(1 + (3 + _)));
	}
}


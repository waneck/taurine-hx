package taurine.tests.ds;

import taurine.ds.Lst;
import taurine.ds.Lst.*;
import taurine.Option.*;
import utest.Assert;

class LstTests
{
	public function new()
	{
	}

	public function testCreate()
	{
		var list = empty();
		Assert.isTrue(list.isEmpty());
		Assert.equals(0,list.count());
		Assert.equals(null,list);
		list = null;
		Assert.isTrue(list.isEmpty());
		Assert.equals(0,list.count());

		list = 1 + list;
		Assert.isFalse(list.isEmpty());
		Assert.equals(1,list.count());

		list = 2 + list;
		Assert.equals(2, list.count());
		Assert.isTrue( list == lst(2,1) );
		Assert.isFalse( list == lst(1,2) );

		Assert.equals(empty(), lst());
	}

	public function testMatch()
	{
		var x = lst(1);
		var hasRun = false;
		lst(1,2,3,4).match(switch _
		{
			case 1 + list:
				hasRun = true;
				Assert.isTrue(list == lst(2,3,4));
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;
		lst(1,2,3,4).match(switch _
		{
			case 1 + (2 + list):
				hasRun = true;
				Assert.isTrue(list == lst(3,4));
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;
		lst(1,2,3,4).match(switch _
		{
			case 1 + (2 + (3 + list)):
				hasRun = true;
				Assert.isTrue(list == lst(4));
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;
		lst(1,2,3,4).match(switch _
		{
			case 1 + lst(2,3,4):
				hasRun = true;
				Assert.isTrue(true);
			case _:
				Assert.fail();
		});
		Assert.isTrue(hasRun); hasRun = false;

		lst().match(switch _
		{
			case lst():
				hasRun = true;
				Assert.isTrue(true);
			case lst(_):
				Assert.fail();
			case _:
				Assert.fail();
		});

		Assert.isTrue(hasRun); hasRun = false;
		lst(1).match(switch _
		{
			case lst():
				Assert.fail();
			case 1 + (2 + _):
				Assert.fail();
			case _:
				Assert.isTrue(true);
				hasRun = true;
		});
		Assert.isTrue(hasRun); hasRun = false;

		Assert.isTrue(lst(1,2,3).matches(1 + (2 + _)));
		Assert.isFalse(lst(1,2,3).matches(1 + (3 + _)));

		Assert.isTrue(lst(none(),some("42")).matches(none() + _));
		Assert.isTrue(lst(none(),some(42)).matches(none() + (some(42) + _)));
	}

	public function testMap()
	{
		Assert.same( lst(1,2,3,4,5).map(function(v) return v * 2), lst(2,4,6,8,10) );
		Assert.same( lst(5,4,3,2,1).revMap(function(v) return v * 2), lst(2,4,6,8,10) );
		Assert.same( lst(1,2,3,4,5).map(function(v) return v * 2 + ""), lst("2","4","6","8","10") );
		Assert.same( lst(5,4,3,2,1).revMap(function(v) return v * 2 + ""), lst("2","4","6","8","10") );
	}

	public function testFilter()
	{
		Assert.same( lst(1,2,3,4,5).filter(function(v) return v % 2 == 0), lst(2,4) );
		Assert.same( lst(5,4,3,2,1).revFilter(function(v) return v % 2 == 0), lst(2,4) );
	}

	public function testIter()
	{
		var arr = [];
		lst(1,2,3,4,5).iter(function(v) arr.push(v));
		Assert.same( [1,2,3,4,5], arr );
		arr = [];
		for (i in lst(1,2,3,4,5))
		{
			arr.push(i);
		}
		Assert.same([1,2,3,4,5], arr);
	}

	public function testConcat()
	{
		Assert.same(lst(1,2,3) * lst(4,5,6), lst(1,2,3,4,5,6));
		Assert.same(lst(1,2,3).revConcat(lst(4,5,6)), lst(3,2,1,4,5,6));
	}
}


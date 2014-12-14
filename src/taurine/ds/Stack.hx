package taurine.ds;
import taurine.Disposable;

/**
	Mutable Stack implementation.
	Implemented using a doubly linked list, it returns a `Disposable` instance when pushing items to it,
	so items can be disposed in an O(1) operation.
**/
//TODO make it thread-safe
@:dce @:access(taurine.ds) class Stack<T>
{
	var head:Node<T>;

	public function new()
	{
		this.head = new Node(null);
	}

	public function push(v:T):Disposable
	{
		var x = new Node(v);
		var h = head;
		x.last = h;
		if (h.next != null)
		{
			x.next = h.next;
		}
		h.next = x;
		return x;
	}

	public function pop():Null<T>
	{
		var ret = head.next;
		if (ret != null)
		{
			ret.dispose();
			return ret.value;
		} else {
			return null;
		}
	}

	public function peek():Null<T>
	{
		var ret = head.next;
		if (ret != null)
		{
			return ret.value;
		} else {
			return null;
		}
	}

	inline public function iter(fn:T->Void)
	{
		var cur = head.next;
		while (cur != null)
		{
			var val = cur.value;
			fn(val);
			cur = cur.next;
		}
	}

	public function iterator():Iterator<T>
	{
		var cur = head.next;
		return {
			hasNext: function() return cur != null,
			next: function() { var val = cur.value; cur = cur.next; return val; }
		};
	}
}

//TODO: make it lock-free atomic
private class Node<T> implements IDisposable
{
	public var value(default,null):T;
	var next:Node<T>;
	var last:Node<T>;

	function new(value)
	{
		this.value = value;
	}

	public function dispose()
	{
		this.value = null;
		var next = this.next,
		    last = this.last;
		if (last != null)
		{
			last.next = next;
		}
		if (next != null)
		{
			next.last = last;
		}
		this.next = null;
		this.last = null;
	}

}

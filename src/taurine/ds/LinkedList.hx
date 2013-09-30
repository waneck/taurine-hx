package taurine.ds;

/**
	Very simple immutable Linked List
**/
class LinkedList<T>
{
	public var h(default,null):T;
	public var tl(default,null):Null<LinkedList<T>>;
	public function new(h,tl)
	{
		this.h = h; this.tl = tl;
	}

	inline public function add(val:T):LinkedList<T>
	{
		return new LinkedList(val,this);
	}
}

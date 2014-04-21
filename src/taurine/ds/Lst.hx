package taurine.ds;
import taurine.*;

/**
	An immutable Linked List implementation
**/
@:dce abstract Lst<T>(LL_Node<T>) from LL_Node<T> to LL_Node<T>
{
	/**
		Gets the head of the list.
		Will not throw an exception if the list is empty - it will return Option.none()
	**/
	var hd(get,never):Option<T>;

	/**
		Gets the tail of the list.
		Returns an empty list if the the list is empty
	**/
	var tl(get,never):Lst<T>;

	/**
		Creates a new Lst from head and tail
	**/
	@:extern inline public function new(cur,next)
	{
		this = new LL_Node(cur,next);
	}

	@:extern inline public function asNode()
	{
		return this;
	}

	@:extern inline private function get_hd():Option<T>
	{
		return this == null ? null : this.cur;
	}

	@:extern inline private function get_tl():Lst<T>
	{
		return this == null ? null : this.next;
	}

	/**
		Returns an empty Lst
	**/
	@:extern inline public static function empty<T>():Lst<T>
	{
		return null;
	}

	/**
		Iterate over the list.
		This function has inline semantics and does not allocate an anonymous function if the function is declared in its argument
	**/
	@:extern inline public function iter(fn:T->Void):Void
	{
		var t = this;
		while (t != null)
		{
			fn(t.cur);
			t = t.next;
		}
	}

	/**
		Tells whether `this` list is empty
	**/
	@:extern inline public function isEmpty():Bool
	{
		return this == null;
	}

	/**
		Applies function `fn` to `[v1, ..., vn]` and builds the list `[fn(v1), ... fn(vn)]`
		Not tail-recursive.
	**/
	public function map<A>(fn:T->A):Lst<A>
	{
		if (this == null)
			return null;
		else
			return fn(this.cur) + (this.next : Lst<T>).map(fn);
	}

	/**
		Returns a reversed Lst of all elements that satisfy the predicate `fn`.
		This function has inline semantics and does not allocate an anonymous function if the function is declared in its argument
	**/
	public function filter(fn:T->Bool):Lst<T>
	{
		if (this == null)
			return null;
		else if (fn(this.cur))
			return this.cur + (this.next : Lst<T>).filter(fn);
		else
			return (this.next : Lst<T>).filter(fn);
	}

	/**
		Applies function `fn` to `[v1, ..., vn]` and builds the list `[fn(vn), ... fn(v1)]`
		This function has inline semantics and does not allocate an anonymous function if the function is declared in its argument
	**/
	@:extern inline public function revMap<A>(fn:T->A):Lst<A>
	{
		var t = this,
				ret = empty();
		while (t != null)
		{
			ret = fn(t.cur) + ret;
			t = t.next;
		}
		return ret;
	}

	/**
		Returns a reversed Lst of all elements that satisfy the predicate `fn`.
		This function has inline semantics and does not allocate an anonymous function if the function is declared in its argument
	**/
	@:extern inline public function revFilter(fn:T->Bool):Lst<T>
	{
		var t = this,
				ret = empty();
		while (t != null)
		{
			if (fn(t.cur))
				ret = t.cur + ret;
			t = t.next;
		}
		return ret;
	}

	/**
		In a list `[a1, ..., an]`, fold is `fn(a1, fn(a2, ... fn(an, acc) ) )`
		This function has inline semantics and does not allocate an anonymous function if the function is declared in its argument
	**/
	@:extern inline public function fold<Acc>(fn:Acc->T->Acc, acc:Acc):Acc
	{
		var t = this;
		while (t != null)
		{
			acc = fn(acc,t.cur);
			t = t.next;
		}
		return acc;
	}

	/**
		Returns a reversed list. Tail-recursive
	**/
	public function rev():Lst<T>
	{
		var t = this,
				ret = empty();
		while (t != null)
		{
			ret = t.cur + ret;
			t = t.next;
		}

		return ret;
	}

	/**
		Creates a new list with element `val` as its head and `list` as its tail
		Example:
		```
		var list = 1 + Lst.empty();
		trace(list); // { 1 }
		list = 2 + list;
		trace(list); // { 2, 1 }
		var list2 = list;
		list = 3 + list;
		trace(list); // { 3, 2, 1 }
		trace(list2); // { 2, 1 }
		```
	**/
	@:extern @:op(A+B) inline public static function add<T>( val:T, list:Lst<T> ) : Lst<T>
	{
		return new Lst( val, list );
	}

	/**
		Returns a new list with all elements from `this` appended to `l2`. Not tail-recursive.
		Example:
		```
		trace( lst(1,2,3) * lst(4,5,6) ); // { 1, 2, 3, 4, 5, 6 }
		```
	**/
	@:op(A*B) public function concat<T>( l2:Lst<T> ):Lst<T>
	{
		if (this == null)
			return l2;
		if (l2 == null)
			return this;

		return this.cur + (this.next : Lst<T>).concat(l2);
	}

	/**
		Returns a new list with all elements from `this` appended in reverse order to `l2`. Tail-recursive.
		Example:
		```
		trace( lst(1,2,3).revConcat(lst(4,5,6)) ); // { 3, 2, 1, 4, 5, 6 }
		```
	**/
	public function revConcat(l2:Lst<T>):Lst<T>
	{
		return fold(function(acc,v) {
			return add(v,acc);
		},l2);
	}

	public function toString()
	{
		if (this == null)
			return "{ }";
		else
			return this.toString();
	}

	@:extern inline public function iterator():LL_NodeIterator<T>
	{
		return new LL_NodeIterator(this);
	}

	/**
		Returns the number of elements in the current list
	**/
	public function count()
	{
		return fold(function(acc,_) return acc + 1, 0);
	}

	/**
		Structural equality
	**/
	@:extern @:op(A == B) inline public function equals(to:Lst<T>):Bool
	{
		return this.equals(to.asNode());
	}

	@:extern @:op(A == B) inline public static function dyneq<T>(lst:Lst<T>, to:Dynamic):Bool
	{
		return Std.is(to,Lst) ? lst.equals(to) : false;
	}

	@:extern @:op(A == B) inline public static function dyneq2<T>(to:Dynamic, lst:Lst<T>):Bool
	{
		return Std.is(to,Lst) ? lst.equals(to) : false;
	}

	/**
		Structural inequality
	**/
	@:extern @:op(A != B) inline public function notEquals(to:Lst<T>):Bool
	{
		return !this.equals(to.asNode());
	}

	@:extern @:op(A != B) inline public static function dynNotEq<T>(lst:Lst<T>, to:Dynamic):Bool
	{
		return Std.is(to,Lst) ? !lst.equals(to) : true;
	}

	@:extern @:op(A != B) inline public static function dynNotEq2<T>(to:Dynamic, lst:Lst<T>):Bool
	{
		return Std.is(to,Lst) ? !lst.equals(to) : true;
	}

	/**
		Creates a list from elements in `exprs`
		Example:
		```
		trace(lst()); // { }
		trace(lst(1)); // { 1 }
		trace(lst(1,2,3,4)); // { 1, 2, 3, 4 }
		```
	**/
	macro public static function lst(exprs:Array<haxe.macro.Expr>):haxe.macro.Expr.ExprOf<Lst<Dynamic>>
	{
		var pos = haxe.macro.Context.currentPos();
		var type = switch haxe.macro.Context.follow(haxe.macro.Context.typeof( { expr: EArrayDecl(exprs), pos:pos })) {
			case TInst(_,[t]):
				t;
			case _: throw "assert";
		};
		var ctype = haxe.macro.TypeTools.toComplexType(type);
		var ret = macro taurine.ds.Lst.empty();
		var i = exprs.length;
		while (i --> 0)
		{
			// var e = macro @:pos(exprs[i].pos) (${exprs[i]} : $ctype);
			var e = exprs[i];
			ret = macro @:pos(exprs[i].pos) new taurine.ds.Lst<$ctype>($e, $ret);
		}
		return ret;
	}

	/**
		Extends the `switch` pattern matching to match on lists with `a + b` meaning `head :: tail`, and `lst(x,y,z)` meaning a list literal
		Example:
		```
		lst(1,2,3,4).match(switch _ {
			//all of the following will match:
			case 1 + lst(2,3,4):
			case _ + lst(2,3,4):
			case 1 + (2 + (3 + (4 + null))):
			case 1 + (2 + (_ + lst(4))):
			case 1 + (2 + (3 + (4 + lst()))):
		});
		```
	**/
	macro public function match(ethis:haxe.macro.Expr, eswitch:haxe.macro.Expr)
	{
		var ret = taurine.ds._internal.MatchHelper.mapSwitch(eswitch,ethis);
		trace(haxe.macro.ExprTools.toString(ret));
		return ret;
	}

	/**
		Performs the same case transformations as `match`, but expects a direct case expression, which will either evaluate to `true` (if `this` conforms to the pattern), or `false`
		Example:
		```
		lst(1,2,3).matches(1 + (2 + _)); // true
		lst(1,2,3).matches(1 + (3 + _)); // false
	**/
	macro public function matches(ethis:haxe.macro.Expr, expr:haxe.macro.Expr):haxe.macro.Expr.ExprOf<Bool>
	{
		return taurine.ds._internal.MatchHelper.getMatches(expr,ethis);
	}
}

class LL_Node<T>
{
	public var next(default,null):LL_Node<T>;
	public var cur(default,null):T;

	public function new(cur,next)
	{
		this.cur = cur;
		this.next = next;
	}

	inline public function iterator():LL_NodeIterator<T>
	{
		return new LL_NodeIterator(this);
	}

	inline public function asList():Lst<T>
	{
		return this;
	}

	public function equals(to:LL_Node<T>):Bool
	{
		if (this == to) return true;
		var c1 = this, c2 = to;
		while (c1 != null && c2 != null)
		{
			if (c1.cur != c2.cur)
				return false;
			c1 = c1.next;
			c2 = c2.next;
		}
		if (c1 != null || c2 != null)
			return false;
		return true;
	}

	public function toString()
	{
		var ret = new StringBuf();
		ret.add("{ ");
		var t = this;
		var first = true;
		while(t != null)
		{
			if (first)
				first = false;
			else
				ret.add(', ');
			ret.add(t.cur);
			t = t.next;
		}
		ret.add(" }");
		return ret.toString();
	}
}

private class LL_NodeIterator<T>
{
	var current(default, null):LL_Node<T>;
	inline public function new(cur)
	{
		this.current = cur;
	}

	inline public function hasNext()
	{
		return current != null;
	}

	inline public function next()
	{
		var ret = current.cur;
		current = current.next;
		return ret;
	}
}

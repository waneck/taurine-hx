package taurine;

/**
	An Option is a wrapper type which can either have a value (Some) or not a
	value (None).
**/
@:dce abstract Option<T>(Null<T>) from T
{
	@:extern inline public function new(val)
	{
		this = val;
	}

	@:extern inline public static function opt<T>(val:Null<T>):Option<T>
	{
		return new Option(val);
	}

	@:extern inline public static function none<T>():Option<T>
	{
		return null;
	}

	@:extern inline public static function some<T>(v:T):Option<T>
	{
		if (v == null) throw "Option expected Some but entered null";
		return new Option(v);
	}

	@:extern inline public function isSome():Bool
	{
		return this != null;
	}

	@:extern inline public function isNone():Bool
	{
		return this == null;
	}

	@:extern inline public function force():T
	{
		return this;
	}

	@:from @:extern inline public static function fromStd<T>(opt:haxe.ds.Option<T>):Option<T>
	{
		return switch opt {
			case None:
				new Option(null);
			case Some(s):
				new Option(s);
		}
	}

	@:to @:extern inline public function toStd():haxe.ds.Option<T>
	{
		return this == null ? haxe.ds.Option.None : haxe.ds.Option.Some(this);
	}

	@:extern inline public function map<A>(fn:T->A):Option<A>
	{
		if (this == null)
		{
			return null;
		} else {
			return fn(this);
		}
	}

	@:extern inline public function mapDefault<A>(fn:T->A, orDefault:A):A
	{
		if (this == null)
		{
			return orDefault;
		} else {
			return fn(this);
		}
	}

	@:extern inline public function may(fn:T->Void):Void
	{
		if (this != null)
			fn(this);
	}

	@:extern inline public function val<T>():T
	{
		if (this == null) throw "Option is empty";
		return this;
	}

	@:extern inline public function orUse<T>(fn:Void->T):T
	{
		if (this == null)
			return fn();
		else
			return this;
	}

	/**
		Extends the `switch` pattern matching to match on Option with None / Some() semantics
		Example:
		```
		some(10).match(switch _ {
			case none:
			case some(5):
			case some(10): //here
		});
		```
	**/
	macro public function match(ethis:haxe.macro.Expr, eswitch:haxe.macro.Expr)
	{
		var ret = taurine.ds._internal.MatchHelper.mapSwitch(eswitch,ethis);
		// trace(haxe.macro.ExprTools.toString(ret));
		return ret;
	}

	/**
		Performs the same case transformations as `match`, but expects a direct case expression, which will either evaluate to `true` (if `this` conforms to the pattern), or `false`
		Example:
		```
		some(10).matches(none); // false
		some(10).matches(some(_)); //true
		none().matches(none); //true
		```
	**/
	macro public function matches(ethis:haxe.macro.Expr, expr:haxe.macro.Expr):haxe.macro.Expr.ExprOf<Bool>
	{
		return taurine.ds._internal.MatchHelper.getMatches(expr,ethis);
	}
}

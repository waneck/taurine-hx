package taurine.async._internal;
import haxe.macro.Expr;
import haxe.macro.ExprTools.*;
import haxe.macro.Context.*;
import haxe.macro.Type;

/**
	Generator is a special routine that can be used to control the iteration behaviour of a loop.
	A generator is very similar to a function that returns an array, in that a generator has parameters,
	can be called, and generates a sequence of values.
	However, instead of building an array containing all the values and returning them all at once,
	a generator yields the values one at a time, which requires less memory and allows the caller to
	get started processing the first few values immediately. In short, a generator looks like a
	function but behaves like an iterator.
	*source: Wikipedia*

	This class brings generators to Haxe with the use of macros.
 **/
class Generator
{
	private var selfref:Expr;
	private var isClass:Bool;

	public function new()
	{
		this.isClass = defined("cpp") || defined("java") || defined("flash9") || defined("cs");
		if (isClass)
			selfref = macro this;
		else
			selfref = macro untyped __this__;
	}

	private static function concat(e1:Expr, e2:Expr):Expr
	{
		return switch [e1.expr,e2.expr]
		{
			case [EBlock(b1), EBlock(b2)]:
				{ expr: EBlock(b1.concat(b2)), pos: e1.pos };
			case [EBlock(b1), _]:
				b1.push(e2);
				e1;
			case [_,EBlock(b2)]:
				{ expr: EBlock([e1].concat(b2)), pos: e2.pos };
			case _:
				{ expr: EBlock([e1,e2]), pos: e2.pos };
		}
	}

	private static function mk_block(e:Expr):Expr
	{
		return switch(e.expr)
		{
			case EBlock(_): e;
			case _: { expr: EBlock([e]), pos:e.pos };
		}
	}

	public function change(e:Expr):Expr
	{
		var state = 0;

		//takes care of changing var names to unique names,
		//and mark the ones that need to be persistent.
		//marks the interruptible statements
		var externals = new Map(),
				scope = [new Map()];
		var curScope = scope[0], vid = 0;

		function collectIdents(e:Expr, ?out:Array<String>):Expr
		{
			function collectIdents(e)
			{
				return switch(e.expr)
				{
					case EConst(CIdent(i)):
						if(out != null) out.push(i);
						var id = vid++, name = "%v" + id + "@" + v.name;
						curScope.set(v.name, name);
						{ expr:EConst(CIdent(name)), pos: e.pos };
					default:
						map(e, collectIdents);
				}
			}
		}

		function pushBlock() scope.push(curScope = new Map());

		function popBlock() { scope.pop(); curScope = scope[scope.length-1]; }

		function pre(e:Expr):Expr
		{
			return switch(e.expr)
			{
			case EMeta("yield", val):
				state++;
				map(e, pre);
			case EVars(vars):
				var vars2 = [];
				for (v in vars)
				{
					var id = vid++, name = "%v" + id + "@" + v.name;
					curScope.set(v.name, name);
					vars2.push({ type:v.type, name:name, expr: v.expr != null ? pre(v.expr) : null });
				}
				{ expr: EVars(vars2), pos: e.pos };
			case EFor({ expr:EIn(e1,e2) } = efor, expr):
				var cstate = state;
				pushBlock();
				var e1 = collectIdents(e1);
				var ret = { expr: EFor({ expr:EIn(e1,pre(e2)), pos: efor.pos }, pre(mk_block(expr))), pos: e.pos };
				popBlock();
				if (state != cstate)
					{ expr: EMeta(":interruptible", ret), pos: e.pos };
				else
					ret;
			case ETry(etry,ecatches):
				var cstate = state;
				var t = pre(mk_block(etry));
				var ec = [];
				for (c in ecatches)
				{
					var id = vid++; name = "%v" + id + "@" + c.name;
					pushBlock();
					curScope.set(c.name,name);
					ec.push({ type:c.type, name:name, expr: pre(mk_block(c)) });
					popBlock();
				}
				var ret = { expr: ETry(t,ec), pos : e.pos };
				if (state != cstate)
					{ expr: EMeta(":interruptible", ret), pos: e.pos };
				else
					ret;
				// @let myvar <-
			case EFunction(f):
				// pushBlock();
				// var args = [];
				// for (a in f.args)
				// {
				// 	var id = vid++; name = "%v" + id + "@" + a.name;
				// 	curScope.set(a.name,name);
				// 	args.push({ value: a.value, type:a.type, opt: a.opt, name: name });
				// }
				// var ret = { expr: EFunction({ ret: f.ret, params:f.params, expr:pre(mk_block(f.expr)), args:args }), pos: e.pos };
				// popBlock();
				// ret;
				//call change and let it handle the function type
				{ expr: EFunction({ ret: f.ret, params: f.params, expr: change(mk_block(f.expr)), args: f.args }), pos :e.pos };
			case ESwitch(cond, cases, edef):
				var cstate = state;
				cond = pre(cond);
				var c2 = [];
				for (c in cases)
				{
					var vals = c.values.map(collectIdents);
					pushBlock();
					c2.push({ values: vals, guard: c.guard == null ? null : pre(c.guard), expr: c.expr == null ? null : pre(c.expr) });
					popBlock();
				}
				var ret = { expr:ESwitch(cond,c2, edef == null ? null : pre(edef)), pos: e.pos };
				if (state != cstate)
					{ expr: EMeta(":interruptible", ret), pos: e.pos };
				else
					ret;

			case EIf(cond,_,_), ETernary(cond,_,_):

			}
		}

	}


}

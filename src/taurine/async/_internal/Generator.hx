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
				scope = [new Map()],
				typesMap = new Map(), //the vars that need types
				usedVars = new Map(),
				states = [{ used: new Map(), written: new Map(), declared: new Map() }];
		var curScope = scope[0], vid = 0, curState = states[0];

		function collectIdents(e):Array<String>
		{
			var arr = [];
			function collectIdents(e)
			{
				switch(e.expr)
				{
					case EConst(CIdent(i)):
						if (i != "_")
							arr.push(i);
					default:
						iter(e, collectIdents);
				}
			}
			collectIdents(e);
			return arr;
		}

		function pushBlock() scope.push(curScope = new Map());
		function popBlock() { scope.pop(); curScope = scope[scope.length-1]; }
		function lookScope(s:String) {for (i in -scope.length...0) if (scope[-i-1].exists(s)) return scope[-i-1].get(s);return null;}
		function mkvar(i:String, ?t)
		{
			var id = vid++, name = 'v%$id%$i';
			curState.declared.set(i, true);
			curScope.set(i, name);
			typesMap.set(name,t);
			return name;
		}

		var modifying = false;

		function pre(e:Expr):Expr
		{
			var wasModifying = modifying;
			modifying = false;
			return switch(e.expr)
			{
			case EMeta({name:"yield"}, val):
				state++;
				states.push(curState = { used: new Map(), written: new Map(), declared: new Map() });
				map(e, pre);
			case EVars(vars):
				var vars2 = [], needType = false;
				for (v in vars)
				{
					var name = mkvar(v.name,v.type);
					vars2.push({ expr : EBinop(OpAssign, macro $i{name}, v.expr != null ? pre(v.expr) : macro null), pos:e.pos });
				}

				{ expr: EMeta({pos:e.pos, params:[], name: ":evars"}, { expr: EBlock(vars2), pos: e.pos }), pos : e.pos };
			case EFor(efor = { expr:EIn(e1,e2) }, expr):
				var cstate = state;
				pushBlock();
				trace(e1);
				// var e1 = collectIdents(e1);
				e2 = pre(e2);

				var ident = collectIdents(e1)[0];
				var name = mkvar(ident);
				expr = pre(mk_block(expr));
				expr = concat(macro @:captureHelper $i{ident} = $i{name}, expr);
				var ret = { expr: EFor({ expr:EIn(e1,e2), pos: efor.pos }, expr), pos: e.pos };
				popBlock();
				if (state != cstate)
					{ expr: EMeta({pos:e.pos, params:[], name: ":interruptible" }, ret), pos: e.pos };
				else
					ret;
			case ETry(etry,ecatches):
				var cstate = state;
				var t = pre(mk_block(etry));
				var ec = [];
				for (c in ecatches)
				{
					pushBlock();
					var name = mkvar(c.name);
					ec.push({ type:c.type, name:name, expr: pre(mk_block(c.expr)) });
					popBlock();
				}
				var ret = { expr: ETry(t,ec), pos : e.pos };
				if (state != cstate)
					{ expr: EMeta({pos:e.pos, params:[], name: ":interruptible" }, ret), pos: e.pos };
				else
					ret;
				// @let myvar <-
			case EFunction(f,_):
				// pushBlock();
				// var args = [];
				// for (a in f.args)
				// {
				// 	var id = vid++; name = "v%" + id + "%" + a.name;
				// 	curScope.set(a.name,name);
				// 	args.push({ value: a.value, type:a.type, opt: a.opt, name: name });
				// }
				// var ret = { expr: EFunction({ ret: f.ret, params:f.params, expr:pre(mk_block(f.expr)), args:args }), pos: e.pos };
				// popBlock();
				// ret;
				//call change and let it handle the function type
				// { expr: EFunction({ ret: f.ret, params: f.params, expr: change(mk_block(f.expr)), args: f.args }), pos :e.pos };
				throw new Error("TODO", e.pos);
			case ESwitch(cond, cases, edef):
				cond = pre(cond);
				var cstate = state;
				var c2 = [];
				for (c in cases)
				{
					var vals = collectIdents({ expr:EBlock(c.values), pos:e.pos });
					pushBlock();
					var exprSet = {expr:EBlock([for (v in vals) { var name = mkvar(v); macro @:captureHelper $i{v} = $i{name}; }]), pos:e.pos};
					c2.push({ values: c.values, guard: c.guard == null ? null : pre(c.guard), expr: c.expr == null ? exprSet : concat(exprSet,pre(c.expr)) });
					popBlock();
				}
				var ret = { expr:ESwitch(cond,c2, edef == null ? null : pre(edef)), pos: e.pos };
				if (state != cstate)
					{ expr: EMeta({pos:e.pos, params:[], name: ":interruptible" }, ret), pos: e.pos };
				else
					ret;

			case EIf(cond,eif,eelse), ETernary(cond,eif,eelse):
				cond = pre(cond);
				var cstate = state;
				eif = pre(eif); eelse = pre(eelse);
				var ret = { expr: EIf(cond,eif,eelse), pos: e.pos };
				if (state != cstate)
					{ expr: EMeta({pos:e.pos, params:[], name: ":interruptible" }, ret), pos: e.pos };
				else
					ret;

			case EWhile(cond,expr,flag):
				cond = pre(cond);
				var cstate = state;
				expr = pre(expr);
				var ret = { expr: EWhile(cond,expr,flag), pos: e.pos };
				if (state != cstate)
					{ expr: EMeta({pos:e.pos, params:[], name: ":interruptible" }, ret), pos: e.pos };
				else
					ret;

			case EConst(CIdent(c)):
				var cca = c.charCodeAt(0);
				if ((cca >= 'A'.code && cca <= 'Z'.code) || c == "true" || c == "null" || c == "false" || c == "trace") {
					e;
				} else {
					var s = lookScope(c);
					var n = s == null ? c : s;
					if (!curState.declared.get(c))
					{
						usedVars.set(n, true);
						curState.used.set(n,true);
						if (wasModifying)
							curState.written.set(n,true);
					}
					if (s == null)
					{
						externals.set(c,true);
						e;
					} else {
						{ expr:EConst(CIdent(s)), pos:e.pos };
					}
				}

			case EBinop(OpAssign | OpAssignOp(_), _,_), EUnop(_,_,_):
				modifying = true;
				map(e,pre);

			case EReturn(_):
				throw new Error("Return not allowed on generator context. Use @yield to yield values", e.pos);

			default:
				map(e,pre);
			}
		}

		e = pre(e);

		//get all types!
		var needTypes = [], allvars = [];
		for (t in typesMap.keys())
		{
			var v = typesMap.get(t);
			allvars.push({ name:t, type:v, expr:null });
			if (v == null && usedVars.get(t))
				needTypes.push(t);
		}

		for (e in externals.keys())
			if (usedVars.get(e))
				needTypes.push(e);

		if (needTypes.length > 0)
		{
			var objdecl = [for (t in needTypes) { field:t, expr:macro $i{t} }];
			var tvars = { expr:EVars(allvars), pos: e.pos };
			var exprToSend = concat(tvars, e);
			exprToSend = concat(exprToSend, { expr:EObjectDecl(objdecl), pos:e.pos });
			switch(follow(typeof(exprToSend)))
			{
				case TAnonymous(a):
					var a = a.get();
					for (f in a.fields)
					{
						typesMap.set(f.name, haxe.macro.TypeTools.toComplexType(f.type));
					}
				case _: throw "assert";
			}
		}

		trace(typesMap);
		return null;

	}


}

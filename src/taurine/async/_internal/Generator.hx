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

	private function mkGoto(i:Int):Expr
	{
		// if defined("cs")
		{
			// return macro untyped __goto__($v{i});
		// } else {
			return macro $selfref.state = $v{i};
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
					case EConst(CIdent(c)):
						var cca = c.charCodeAt(0);
						if (!( (cca >= 'A'.code && cca <= 'Z'.code) || c == "true" || c == "null" || c == "false" || c == "trace" || c == "_") )
							arr.push(c);
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

		var modifying = false, curBlock = null;

		function pre(e:Expr, ?onResult:Expr->Expr):Expr
		{
			var wasModifying = modifying;
			modifying = false;
			return switch(e.expr)
			{
			case EMeta(meta={name:"yield"}, val):
				var val = switch(val.expr)
				{
					case EReturn(val): val;
					case _: val;
				};
				var wasCalled = false, res = onResult == null ?
					function(e) { wasCalled = true; return macro @yield $selfref.__ret__ = $e; } :
					function(e) { wasCalled = true; return macro @yield $selfref.__ret__ = ${onResult(e)}; };
				state++;
				val = pre(val,res);
				if (!wasCalled)
					val = macro @yield ($selfref.__ret__ = $val);
				states.push(curState = { used: new Map(), written: new Map(), declared: new Map() });
				{ expr:EMeta(meta, val), pos: e.pos };
			case EVars([v]):
				var needType = false;
				//we need the var name in order to set onResult (in case the expression is complex)
				//however it can't be added to the scope just yet, as it only takes effect in the end of the scope
				var i = v.name, id = vid++, name = 'v%$id%$i';
				curState.declared.set(i, true);

				var expr = null, wasCalled = false;
				if (v.expr != null)
				{
					inline function onUsed()
					{
						usedVars.set(name, true);
						curState.used.set(name,true);
						curState.written.set(name,true);
					}
					var res = onResult == null ?
						function(e) { wasCalled = true; onUsed(); return macro $i{name} = $e; }:
						function(e) { wasCalled = true; onUsed(); return macro $i{name} = ${onResult(e)}; };
					expr = pre(v.expr,res);
				} else {
					expr = macro untyped __undefined__;
				}

				var ret = null, setExpr = expr;
				if (wasCalled)
					setExpr = macro untyped __undefined__;
				var vars2 = [{ expr : EBinop(OpAssign, macro $i{name}, setExpr), pos:e.pos }];
				ret = { expr: EMeta({pos:e.pos, params:[], name: ":evars"}, { expr: EBlock(vars2), pos: e.pos }), pos : e.pos };
				if (wasCalled)
				{
					curBlock.push(ret);
					ret = expr;
				}

				curScope.set(i, name);
				typesMap.set(name,v.type);
				return ret;

			case EFor(efor = { expr:EIn(e1,e2) }, expr):
				var cstate = state;
				pushBlock();
				// var e1 = collectIdents(e1);
				e2 = pre(e2);

				var ident = collectIdents(e1)[0];
				var name = mkvar(ident);
				expr = pre(mk_block(expr));
				expr = concat(macro @:captureHelper ($i{name} = $i{ident}), expr);
				var ret = { expr: EFor({ expr:EIn(e1,e2), pos: efor.pos }, expr), pos: e.pos };
				popBlock();
				ret;
			case ETry(etry,ecatches):
				var cstate = state;
				var t = pre(mk_block(etry),onResult);
				var ec = [];
				for (c in ecatches)
				{
					pushBlock();
					var name = mkvar(c.name);
					ec.push({ type:c.type, name:name, expr: pre(mk_block(c.expr),onResult) });
					popBlock();
				}
				var ret = { expr: ETry(t,ec), pos : e.pos };
				ret;
				// @var myvar <-
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
					var exprSet = {expr:EBlock([for (v in vals) { var name = mkvar(v); macro @:captureHelper ($i{name} = $i{v}); }]), pos:e.pos};
					c2.push({ values: c.values, guard: c.guard == null ? null : pre(c.guard), expr: c.expr == null ? exprSet : concat(exprSet,pre(c.expr,onResult)) });
					popBlock();
				}
				var ret = { expr:ESwitch(cond,c2, edef == null ? null : pre(edef,onResult)), pos: e.pos };
				ret;

			case EIf(cond,eif,eelse), ETernary(cond,eif,eelse):
				cond = pre(cond);
				var cstate = state;
				eif = pre(mk_block(eif),onResult); eelse = eelse == null ? null : pre(mk_block(eelse),onResult);
				var ret = { expr: EIf(cond,eif,eelse), pos: e.pos };
				ret;

			case EConst(CIdent(c)):
				var cr = collectIdents(e)[0];
				if (cr == null)
				{
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
			case EBlock(bl):
				pushBlock();
				var bl2 = [], i = -1, lst = bl.length - 1;
				var oldBlock = curBlock;
				curBlock = bl2;
				for (b in bl)
				{
					++i;
					function process(e:Expr,onp)
					{
						var cstate = state;
						var c = pre(e,onp);
						if (state != cstate)
							c = macro @:interruptible $c;
						bl2.push(c);
					}

					switch(b.expr)
					{
						case EVars(vars):
							//make sure only one var is declared on EVars
							for(v in vars)
								process({ expr:EVars([v]), pos:b.pos }, null);
						default:
							//check if we'll reroute onResult or apply it already
							if (i==lst && onResult != null) switch(b.expr)
							{
								case EBlock(_), ESwitch(_,_,_), ETry(_,_):
									process(b, onResult);
								default:
									process(b, null);
									bl2[bl2.length-1] = onResult(bl2[bl2.length-1]);
							} else {
								process(b,null);
							}
					}
				}
				curBlock = oldBlock;
				popBlock();
				{ expr:EBlock(bl2), pos:e.pos }

			case EBinop(OpAssign | OpAssignOp(_), _,_), EUnop(_,_,_):
				modifying = true;
				map(e,pre.bind(_));

			case EReturn(_):
				throw new Error("Return not allowed on generator context. Use @yield to yield values", e.pos);

			default:
				map(e,pre.bind(_));
			}
		}

		e = pre(e);
		trace(toString(e));

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

		//okay, now we'll start writing our fields:
		//for each expression, look for @:interruptible meta
		//if found, add state, and change the expression according to its type
		//also revert back the name mangling, the @:captureHelper and @:evars
		var cases = [];
		state = 0;
		function demangle(name:String)
		{
			var l = name.lastIndexOf("%");
			if (l == -1)
				return name;
			return name.substr(l+1);
		}
		function cleanup(e:Expr):Expr
		{
			return switch(e.expr)
			{
				case EMeta({name:":evars"},{ expr:EBlock(bl) }):
					var evars = [for (b in bl) switch(b.expr) {
						case EBinop(OpAssign, {expr:EConst(CIdent(name))}, e2):
							switch(e2.expr)
							{
								case EUntyped({ expr:EConst(CIdent("__undefined__")) }):
									e2 = null;
								default:
									e2 = cleanup(e2);
									if (usedVars.get(name))
										e2 = macro $selfref.$name = $e2;
							}
							{ name: demangle(name), type:typesMap.get(name), expr:e2 };
						case _: throw "assert";
					}];
					{ expr:EVars(evars), pos: e.pos };
				case EMeta({name:":captureHelper"},_):
					{ expr:EBlock([]), pos: e.pos }; //no-op
				case EMeta({name:"yield"}, e):
					e = cleanup(e);
					macro { $e; return true; };
				case EConst(CIdent(c)):
					if (externals.exists(c))
					{
						macro $selfref.$c;
					} else if (usedVars.get(c)) {
						macro $selfref.$c;
					} else {
						{ expr: EConst(CIdent( demangle(c) )), pos: e.pos };
					}
				case _:
					//@var a <- something()
					map(e, cleanup);
			}
		}

		// trace(haxe.macro.ExprTools.toString( cleanup(e) ));
		var onEnd = null;

		//cuts expressions when yield is found
		cases.push(null);
		var delays:Array<Array<Int->Void>> = [];
		function runDelays(depth:Int, c:Int)
		{
			for (d in (depth+1)...delays.length)
			{
				var d = delays[d];
				if (d != null)
				{
					var cd = null;
					while( (cd = d.pop()) != null )
						cd(c);
				}
			}
		}
		inline function addDelay(depth:Int, delay:Int->Void):Void
		{
			var d = delays[depth];
			if (d == null)
			{
				delays[depth] = d = [];
			}
			d.push(delay);
		}
		function cut(e:Expr, depth:Int, ?thisCase:Int):Expr
		{
			if (thisCase == null)
				thisCase = cases.length - 1;
			var setNextState = null;
			var pos = getPosInfos(e.pos);
			switch(e.expr)
			{
			case EBlock(bl):
				var bl2 = [];
				bl2.push(macro $v{'start:: depth $depth, case $thisCase'});
				for (i in 0...bl.length)
				{
					var e = bl[i];
					switch(e.expr)
					{
					case EMeta({name:":interruptible"}, itr):
						itr = switch(itr)
						{
							case macro @:evars $_:
								cleanup(itr);
							case _: itr;
						}
						//start cutting expressions off
						switch(itr.expr)
						{
						case EIf(econd,eif,eelse):
							econd = cleanup(econd); //no yield can be here; TODO: make sure it happens
							var blockContinues = i != bl.length - 1;
							var ccase = cases.length;

							eif = cut(eif,depth+1,thisCase);
							if (eelse != null)
								eelse = cut(eelse,depth+1,thisCase);
							runDelays(depth, cases.length);
							e.expr = EIf(econd,eif,eelse);
						case EMeta({name:"yield"}, _):
							bl2.push(macro $v{thisCase});
							var possibleGoto = macro null;
							setNextState = function(state:Int)
							{
								if (state - thisCase > 1)
								{
									var g = mkGoto(state);
									possibleGoto.expr = g.expr;
								}
							};
							bl2.push(possibleGoto);
							e = cleanup(e);
						case EBlock(_):
							e = cut(itr,depth+1, thisCase);
							runDelays(depth,cases.length);
						default:
							throw "NI";
						}
					case _:
						bl2.push( cleanup(e) );
						continue;
					}
					//if we are here, we found (and handled) an @:interruptible
					bl2.push(e);

					if (i < (bl.length - 1)) //there is still code on this block
					{
						//recursively cut and add the result as a case
						var idx = cases.push(null) - 1;
						var remainingCode = cut({ expr: EBlock([for(i in (i+1)...bl.length) bl[i]]), pos: e.pos },depth);
						cases[idx] = remainingCode;

						runDelays(depth,cases.length-1);

						//if the index is different from the next case (thisCase + 1),
						//add a specific goto statement
						if (idx != thisCase + 1)
						{
							if (setNextState != null)
							{
								setNextState(idx);
							} else {
								bl2.push(mkGoto(idx));
								if (depth != 0)
									bl2.push(macro continue); //TODO see which cases we can avoid this
							}
						}

						return { expr: EBlock(bl2), pos: e.pos };
					} else {
						var possibleGoto = macro null;
						addDelay(depth, function(c) {
							if (cases.length - 1 - thisCase > 1)
							{
								var g = mkGoto(c);
								possibleGoto.expr = g.expr;
							} else {
								var g = macro $v{'soft goto: ${cases.length - 1}'};
								possibleGoto.expr = g.expr;
							}
						});
						bl2.push(macro $v{'depth $depth, case $thisCase'});
						bl2.push(possibleGoto);
						return { expr: EBlock(bl2), pos: e.pos };
					}
				}
				//situation: we are currently at thisCase.
				//and either we didn't find any @:interruptible
				//(meaning we're the remainder of an already cut @:interruptible expression)
				//or we found it, but there's nothing else in the block.
				//in this case, we don't know what's our target case after this;
				//so we will add it to delays[depth]
				var possibleGoto = macro null;
				addDelay(depth, function(c) {
					if (cases.length - 1 - thisCase > 1)
					{
						var g = mkGoto(c);
						possibleGoto.expr = g.expr;
					} else {
						var g = macro $v{'soft goto: ${cases.length - 1}'};
						possibleGoto.expr = g.expr;
					}
				});
				bl2.push(macro $v{'depth $depth, case $thisCase'});
				bl2.push(possibleGoto);

				return { expr: EBlock(bl2), pos: e.pos };
			default:
				return cleanup(e);
			}
		}

		e = cut(e,0);
		var d = null;
		for (da in delays)
			if (da != null)
				while ( (d = da.pop()) != null )
					d(cases.length-1); //set goto to the correct case
		// trace(toString(e));
		// trace(cases.length);
		cases[0] = e;
		// cases[0] = e;
		// trace([for (c in cases) haxe.macro.ExprTools.toString( c ) ]);
		// trace(cases);

		var i = 0;

		cases.push(macro { return false; });
		var sw = { expr : ESwitch(macro $selfref.state++, [for (c in cases) { values:[macro $v{i++}], expr:c }], macro throw ('Invalid state: ' + ($selfref.state - 1))), pos: e.pos };
		sw = macro while(true) { trace("state",$selfref.state); $sw; };
		if (!isClass)
		{
			var objdecl = [{ field:"state", expr: macro 0 }];
			for (e in externals.keys())
				if (usedVars.get(e))
					objdecl.push({ field: e, expr: macro $i{e} });
			for (t in typesMap.keys())
				if (!externals.exists(t) && usedVars.get(t))
					objdecl.push({ field: t, expr: macro null });
			objdecl.push({ field: "hasNext", expr: macro function() $sw });
			objdecl.push({ field: "next", expr: macro function() return $selfref.__ret__ });
			e = { expr: EObjectDecl(objdecl), pos: e.pos };
			e = macro (cast $e : Iterator<Dynamic>);
		}
		trace(toString(e));

		return e;
	}


}

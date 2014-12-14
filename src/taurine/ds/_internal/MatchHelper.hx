package taurine.ds._internal;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
import haxe.macro.Type;

using haxe.macro.Tools;

class MatchHelper
{
	public static function mapSwitch(e:Expr, ?ethis:Expr):Expr
	{
		switch(e.expr)
		{
			case ESwitch(cond,cases,edef):
				return { expr: new MatchMapper(ethis,cond,cases,edef).getMapped(), pos: e.pos };
			case _:
				throw new Error('Switch expression expected', e.pos);
		}
	}

	public static function getMatches(expr:Expr, ethis:Expr):Expr
	{
		return { expr: new MatchMapper(ethis,ethis,[{ values:[expr], guard:null, expr:macro true }], macro false).getMapped(), pos: expr.pos };
	}

	// abstract to underlying type
	public static function a2u(t:Type):Type
	{
		switch (t) {
			case TAbstract(a,tl):
				var u = a.get().type;
				tl = [ for (t in tl) switch (Context.follow(t)) { case TMono(_): TDynamic(null); case _: t; } ];
				if (u != null)
					return tl.length > 0 ? u.applyTypeParameters(a.get().params,tl) : u;
				else
					return TAbstract(a,[ for (t in tl) a2u(t) ]);
			case _:
				return t.map(a2u);
		}
	}

	public static function a2uComplex(t:Type):ComplexType
	{
		while(true)
		{
			inline function recurse(newT:Type) { t = newT; return continue; }
			switch(t) {
				case TInst(_.get() => { pack:[], name:"Array" }, [a]):
					var c = a2uComplex(a);
					return macro : Array<$c>;
				case TAbstract(_,_) | TEnum(_,_) | TInst(_,_) | TType(_,_):
					return a2u(t).toComplexType();
				case TMono(t):
					if (t == null)
						return macro : Dynamic;
					else
						recurse(t.get());
				case TLazy(f):
					recurse(f());
				case TDynamic(_):
					return macro :Dynamic;
				case TAnonymous(_.get() => anon):
					var fields = [];
					for (f in anon.fields)
					{
						function getAcc(acc:VarAccess,get:Bool)
						{
							return switch (acc) {
								case AccNormal:'default';
								case AccNo: 'null';
								case AccNever: 'never';
								case AccCall: get ? 'get' : 'set';
								case _: 'default';
							}
						}
						var kind = switch (f.kind) {
							case FVar(get,set):
								FProp( getAcc(get,true), getAcc(set,false), a2uComplex(f.type) );
							case FMethod(_):
								FProp( 'default', 'never', a2uComplex(f.type) );
						};
						fields.push({ name:f.name, pos: f.pos, kind: kind });
					}
					return TAnonymous( cast fields);
				case t:
					a2u(t).toComplexType();
			}
		}
	}

	//underlying to abstract
	public static function u2a(t:Type):Type
	{
		var origT = t;
		while (true)
		{
			inline function recurse(newT:Type) { t = newT; return continue; }

			switch (t) {
				case TInst(_.get() => { pack:['taurine','ds'], name:'LL_Node' }, [t]):
					return switch (Context.getType('taurine.ds.Lst')) {
						case TAbstract(a,_):
							TAbstract(a,[ u2a(t) ]);
						case _:
							throw 'assert';
					}
				case TType(_.get() => { pack:[], name:'Null' }, [t]):
					switch [ Context.follow(t), Context.getType('taurine.Option') ] {
						case [ TInst(_.get() => { pack: ['taurine','ds'], name:'LL_Node' }, _), _ ]:
							recurse(t);
						case [ _, TAbstract(a,_) ]:
							return TAbstract(a, [ u2a(t) ]);
						case _:
							throw "assert";
					}
				case TInst(_,[]):
					return origT;
				case TEnum(_,[]):
					return origT;
				case TAbstract(_,[]):
					return origT;
				case TMono(t2):
					var t2 = t2.get();
					if (t2 != null)
						recurse(t2);
					else
						return origT;
				case TInst(i,args):
					var change = false;
					var a2 = [ for (a in args) { var m = u2a(a); if (m != a) change = true; m; } ];
					if (change)
						return TInst(i,a2);
					else
						origT;
				case TEnum(e,args):
					var change = false;
					var a2 = [ for (a in args) { var m = u2a(a); if (m != a) change = true; m; } ];
					if (change)
						return TEnum(e,a2);
					else
						origT;
				case TType(_,_):
					recurse(Context.follow(t,true));
				case TAbstract(a,args):
					var change = false;
					var a2 = [ for (a in args) { var m = u2a(a); if (m != a) change = true; m; } ];
					if (change)
						return TAbstract(a,a2);
					else
						return origT;
				case TFun(args,ret):
					var change = false;
					var a2 = [ for (a in args) { var m = u2a(a.t); if (m != a.t) change = true; { name:a.name, opt:a.opt, t:m }; } ];
					var r2 = u2a(ret);
					if (r2 != ret)
						change = true;
					if (change)
						return TFun(a2,r2);
					else
						return origT;
				case TDynamic(_):
					return origT;
				case TLazy(f):
					recurse(f());
				case TAnonymous(a):
					//TODO
					return origT;
			}
		}
	}

	public static function u2aComplex(t:Type, changed: { changed:Bool }):ComplexType
	{
		while(true)
		{
			inline function recurse(newT:Type) { t = newT; return continue; }
			switch(t) {
				case TInst(_.get() => { pack:[], name:"Array" }, [a]):
					var c = u2aComplex(a,changed);
					return macro : Array<$c>;
				case TAbstract(_,_) | TEnum(_,_) | TInst(_,_) | TType(_,_):
					var ret = u2a(t);
					if (ret != t)
						changed.changed = true;
					return ret.toComplexType();
				case TMono(t):
					if (t == null)
						return macro : Dynamic;
					else
						recurse(t.get());
				case TLazy(f):
					recurse(f());
				case TDynamic(_):
					return macro : Dynamic;
				case TAnonymous(_.get() => anon):
					var fields = [];
					for (f in anon.fields)
					{
						function getAcc(acc:VarAccess,get:Bool)
						{
							return switch (acc) {
								case AccNormal:'default';
								case AccNo: 'null';
								case AccNever: 'never';
								case AccCall: get ? 'get' : 'set';
								case _: 'default';
							}
						}
						var kind = switch (f.kind) {
							case FVar(get,set):
								FProp( getAcc(get,true), getAcc(set,false), u2aComplex(f.type,changed) );
							case FMethod(_):
								FProp( 'default', 'never', u2aComplex(f.type,changed) );
						};
						fields.push({ name:f.name, pos: f.pos, kind: kind });
					}
					return TAnonymous( cast fields);
				case _:
					var ret = u2a(t);
					if (ret != t)
						changed.changed = true;
					return ret.toComplexType();
			}
		}
	}
}

private class MatchMapper
{
	var cond:Expr;
	var cases:Array<Case>;
	var def:Null<Expr>;
	var ethis:Null<Expr>;

	public function new(ethis,cond,cases,def)
	{
		this.cond = cond;
		this.cases = cases;
		this.def = def;
		this.ethis = ethis;
	}

	public function getMapped()
	{
		mapCond();
		return ESwitch(cond,[ for (c in cases) {
			var captured = [];
			{
				values: c.values.map(function(e) return mapCaseExpr(e,captured)),
				guard: c.guard,
			  expr: concat([ for (c in captured) macro taurine.ds._internal.Macros.mapArg($c) ], c.expr)
			};
		} ], def);
	}

	function concat(exprs:Array<Expr>, e:Expr)
	{
		if (exprs.length == 0)
			return e;
		return switch e.expr {
			case EBlock(bl):
				{ expr:EBlock(exprs.concat(bl)), pos:e.pos };
			case _:
				{ expr:EBlock(exprs.concat([e])), pos:e.pos };
		}
	}

	function mapCond()
	{
		if (ethis != null)
		{
			function map(e:Expr)
			{
				switch(e.expr)
				{
					case EConst(CIdent("_")):
						return ethis;
					case _:
						return ExprTools.map(e,map);
				}
			}
			cond = map(cond);
		}
		switch (cond.expr) {
			case EArrayDecl(el):
				var e2 =[];
				for (e in el)
				{
					var t = Context.typeof(e),
							complex = MatchHelper.a2uComplex(t);
					e2.push(macro ( (cast $e) : $complex));
				}
				cond = { expr:EArrayDecl(e2), pos:cond.pos };
			case _:
				var t = Context.typeof(cond),
						complex = MatchHelper.a2uComplex(t);
				cond = (macro ( (cast $cond) : $complex));
		}
	}

	function mapCaseExpr(e:Expr,captured:Array<Expr>):Expr
	{
		switch(e.expr)
		{
			case EConst(CIdent(i)):
				if (i != '_')
					captured.push(e);
				return e;
			case EBinop(OpAdd, e1, e2): // list hd :: tl
				e2 = listCase(mapCaseExpr(e2,captured));
				return macro @:pos(e.pos) { cur: ${mapCaseExpr(e1,captured)}, next: $e2 };
			case ECall({ expr:EConst(CIdent("none")) }, []),
					 EConst(CIdent("none")):
				return macro @:pos(e.pos) null;
			case ECall({ expr:EConst(CIdent("some")) }, [v]):
				return macro @:pos(e.pos) ${mapCaseExpr(v,captured)};
			case ECall({ expr:EConst(CIdent("lst")) }, el):
				var i = el.length;
				var e = macro null;
				while (i --> 0)
				{
					e = macro @:pos(el[i].pos) { cur: ${mapCaseExpr(el[i],captured)}, next: $e };
				}
				return e;
			case EMeta(_,_) | EParenthesis(_):
				return ExprTools.map(e,function(e) return mapCaseExpr(e,captured));
			case _:
				return ExprTools.map(e,function(e) return mapCaseExpr(e,captured));
		}
	}

	static function listCase(e:Expr):Expr
	{
		switch(e.expr)
		{
			// case EConst(CIdent(id)):
			// 	return macro _.asList() => $e;
			// case EParenthesis(p), EMeta(_,p), EDisplay(p,_):
			// 	return listCase(p);
			case _:
				return e;
		}
	}
}

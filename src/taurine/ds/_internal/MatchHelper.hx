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
		var t = Context.typeof(ethis);
		return ESwitch(cond,[ for (c in cases) { values: c.values.map(function(e) return mapCaseExpr(e,t)), guard: c.guard, expr: c.expr } ], def);
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
		// convert needed abstracts to their underlying type
		function map(e:Expr)
		{
			switch( e.expr )
			{
				case EArrayDecl(_),
							EObjectDecl(_),
							EParenthesis(_):
				//recurse
				return ExprTools.map(e,map);
				case _: switch Context.follow(Context.typeof(e))
				{
					case TAbstract(_.get() => { pack: ['taurine','ds'], name: 'Lst' }, _):
						return macro @:pos(e.pos) $e.asNode();
					case _:
						return e;
				}
			}
		}
		cond = map(cond);
	}

	function mapCaseExpr(e:Expr,t:Type):Expr
	{
		switch(e.expr)
		{
			case EBinop(OpAdd, e1, e2): // list hd :: tl
				var t2 = switch (t.follow())
				{
					case TAbstract(_.get() => { pack: ['taurine','ds'], name: 'Lst' } ,[t2]):
						t2;
					case TInst(_.get() => { pack: ['taurine','ds','_Lst'], name: 'LL_NodeIterator' } ,[t2]):
						t2;
					default:
						return e;
				};
				e2 = listCase(mapCaseExpr(e2,t));
				return macro @:pos(e.pos) { cur: ${mapCaseExpr(e1,t2)}, next: $e2 };
			case ECall({ expr:EConst(CIdent("none")) }, []),
					 EConst(CIdent("none")):
				switch (t.follow())
				{
					case TAbstract(_.get() => { pack: ['taurine'], name:'Option' }, [t2]):
						return macro @:pos(e.pos) null;
					default:
						return e;
				}
			case ECall({ expr:EConst(CIdent("some")) }, [v]):
				switch(t.follow())
				{
					case TAbstract(_.get() => { pack: ['taurine'], name: 'Option' }, [t2]):
						return macro @:pos(e.pos) _.force() => ${mapCaseExpr(v,t2)};
					default:
						return e;
				}
			case ECall({ expr:EConst(CIdent("lst")) }, el):
				var t2 = switch (t.follow())
				{
					case TAbstract(_.get() => { pack: ['taurine','ds'], name: 'Lst' } ,[t2]):
						t2;
					case TInst(_.get() => { pack: ['taurine','ds','_Lst'], name: 'LL_NodeIterator' } ,[t2]):
						t2;
					default:
						return e;
				};
				var i = el.length;
				var e = macro null;
				while (i --> 0)
				{
					e = macro @:pos(el[i].pos) { cur: ${mapCaseExpr(el[i],t2)}, next: $e };
				}
				return e;
			case EMeta(_,_) | EParenthesis(_):
				return ExprTools.map(e,function(e) return mapCaseExpr(e,t));
			case _:
				return e;
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

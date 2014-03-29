package taurine.ds._internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;

class MatchHelper
{
	public static function mapSwitch(e:Expr, ?ethis:Expr):Expr
	{
		switch(e.expr)
		{
			case ESwitch(cond,cases,edef):
				cond = mapCond(cond,ethis);
				return { expr:ESwitch(cond,[ for (c in cases) { values:c.values.map(mapCaseExpr), guard:c.guard, expr:c.expr } ], edef), pos: e.pos };
			case _:
				throw new Error('Switch expression expected', e.pos);
		}
	}

	public static function getMatches(expr:Expr, ethis:Expr):Expr
	{
		return { expr: ESwitch(mapCond(ethis,ethis), [{ values:[mapCaseExpr(expr)], guard:null, expr:macro true }], (macro false)), pos:expr.pos };
	}

	public static function mapCond(cond:Expr, ethis:Expr):Expr
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
						return macro $e.asNode();
					case _:
						return e;
				}
			}
		}
		cond = map(cond);
		return cond;
	}

	public static function mapCaseExpr(e:Expr):Expr
	{
		switch(e.expr)
		{
			case EBinop(OpAdd, e1, e2): // list hd :: tl
				e2 = listCase(mapCaseExpr(e2));
				return macro @:pos(e.pos) { cur: ${mapCaseExpr(e1)}, next: $e2 };
			case ECall({ expr:EConst(CIdent("lst")) }, el):
				var i = el.length;
				var e = macro null;
				while (i --> 0)
				{
					e = macro @:pos(el[i].pos) { cur: ${mapCaseExpr(el[i])}, next: $e };
				}
				return e;
			case _:
				return ExprTools.map(e,mapCaseExpr);
		}
	}

	public static function listCase(e:Expr):Expr
	{
		switch(e.expr)
		{
			case EConst(CIdent(id)):
				return macro _.asList() => $e;
			case EParenthesis(p), EMeta(_,p), EDisplay(p,_):
				return listCase(p);
			case _:
				return e;
		}
	}
}

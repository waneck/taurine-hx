package taurine.threads._internal;
import haxe.macro.Expr;
import haxe.macro.Context;

/**
	Macro tools for locks
**/
class LockHelper
{
	private static var id = 0;

	public static function transformLock(ethis:Expr, eblock:Expr, forceVoid:Bool):Expr
	{
		var id = id++;
		if (id == 0)
		{
			Context.onMacroContextReused(function() {
				LockHelper.id = 1;
				return true;
			});
		}

		var rethrow =
			if (Context.defined("neko"))
				function (e:Expr) return macro neko.Lib.rethrow($e);
			else if (Context.defined("cs"))
				function (_) return macro untyped __rethrow__();
			else if (Context.defined("cpp"))
				function(e:Expr) return macro cpp.Lib.rethrow($e);
			else if (Context.defined("php"))
				function(e:Expr) return macro php.Lib.rethrow($e);
			else
				function (e:Expr) return macro throw $e;

		// make sure we don't exit this context before calling release
		var varName = "__mutex" + id;
		var loopCount = 0;
		function map(e:Expr):Expr
		{
			switch e.expr
			{
				case EBreak | EContinue if (loopCount == 0):
					macro { $i{varName}.release(); $e };
				case EReturn(_):
					macro { $i{varName}.release(); $e };
				case EWhile(cond,expr,kind):
					var cond = map(cond);
					loopCount++;
					var expr = map(expr);
					loopCount--;
					return { expr: EWhile(cond,expr,kind), pos:e.pos };
				case EFor(it,expr):
					it = map(it);
					loopCount++;
					expr = map(expr);
					loopCount--;
					return { expr: EFor(it,expr), pos: e.pos };
				case EFunction(_,_):
					e;
				default:
					haxe.macro.ExprTools.map(e,map);
			}
		}
		eblock = map(eblock);

		var bltype = forceVoid ? null : Context.getExpectedType();
		switch(Context.follow(bltype))
		{
			case null | TAbstract(_.get() => { pack:[], name:"Void" }, _):
				return macro {
					var $varName = $ethis;
					$i{varName}.acquire();
					try
					{
						$eblock;
						$i{varName}.release();
					}
					catch(e:Dynamic)
					{
						$i{varName}.release();
						${rethrow(e)};
					}
				};
			default:
				return macro {
					var $varName = $ethis;
					$i{varName}.acquire();
					try
					{
						var ___ret___ = $eblock;
						$i{varName}.release();
						___ret___;
					}
					catch(e:Dynamic)
					{
						$i{varName}.release();
						${rethrow(e)};
					}
				};
		}
	}
}

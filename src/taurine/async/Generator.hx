package taurine.async;
#if macro
import haxe.macro.Expr;
#end

/**
	This is a
**/
class Generator
{
	macro public static function test(e:Expr):Expr
	{
		new taurine.async._internal.Generator().change(e);
		return macro null;
	}
}

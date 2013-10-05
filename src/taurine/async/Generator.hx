package taurine.async;
#if macro
import haxe.macro.Expr;
#end

/**
	This is a
**/
class Generator
{
	macro private static function test(e:Expr):Expr
	{
		return new taurine.async._internal.Generator().change(e);
	}
}

package taurine.mem;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class StructBuild
{
	public static function build():Array<Field>
	{
		var fields = Context.getBuildFields();
	}
}
#end

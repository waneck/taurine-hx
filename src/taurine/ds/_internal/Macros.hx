package taurine.ds._internal;
#if macro
using haxe.macro.Tools;
#end

class Macros
{
	macro public static function mapArg(arg:haxe.macro.Expr):haxe.macro.Expr
	{
		var name = switch (arg) {
			case macro $i{ident}:
				ident;
			case _:
				throw new haxe.macro.Expr.Error('Invalid argument mapping. Expected CIdent', arg.pos);
		};

		var changed = { changed: false };
		var t = haxe.macro.Context.typeof(arg),
				mapped = taurine.ds._internal.MatchHelper.u2aComplex(t,changed);
		if (changed.changed)
		{
			return macro var $name : $mapped =  cast $arg;
		} else {
			return macro null;
		}
	}
}

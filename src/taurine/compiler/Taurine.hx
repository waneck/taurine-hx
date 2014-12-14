package taurine.compiler;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

class Taurine
{
	macro public static function beforeCompile():Void
	{
		checkThreading();
	}

	private static function checkThreading()
	{
		if (Context.defined("TAURINE_NO_THREADS"))
		{
			return;
		} else if (Context.defined("TAURINE_CUSTOM_THREAD")) {
			var pack = Context.definedValue("TAURINE_CUSTOM_THREAD");
			for (cls in ['Thread','Mutex','Lock'])
			{
				var tname = (pack == "" ? cls : pack + "." + cls);
				var t = {
					pack: pack.split('.'),
					name: cls,
					pos: Context.currentPos(),
					kind: TDAlias(TPath({ pack:pack.split('.'), name:cls })),
					fields:[]
				};
				Context.defineType(t);
			}
		} else if (Context.defined("neko")) {
			if (Context.defined("interp")) {
				Compiler.define("TAURINE_NO_THREADS");
			}
		} else if (!Context.defined("cs") && Context.defined("java") && Context.defined("cpp")) {
			//no thread support
			Compiler.define("TAURINE_NO_THREADS");
		}
	}
}

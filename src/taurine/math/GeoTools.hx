package taurine.math;
// #if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
// #end

/**
	Provides static tools to make vector / matrix manipulation easier

	Recommended use:
	`import taurine.math.GeoTools.*`
**/
class GeoTools
{

	macro public static function mat2d(exprs:Array<Expr>):Expr
	{
		return mat2d_internal(exprs);
	}

// #if macro
	public static function mat2d_internal(exprs:Array<Expr>):Expr
	{
		var pos = Context.currentPos();
		if (exprs.length == 0)
			throw new Error('Invalid number of arguments for this call', pos);
		var matlen = 6, name = "Mat2D", matlen_real = 8;
		var ret = [], cindex = 0;
		var p = Context.getPosInfos(pos);
		var ename = new haxe.io.Path(p.file).dir + "_" + p.min;
		var main = { expr: EConst(CIdent(ename)), pos: pos };

		function processArr(adecl:Array<Expr>, pos)
		{
			if (adecl.length != matlen)
				throw new Error('($name) Invalid number of arguments for $name definition: Expected $matlen; Got ${adecl.length}', pos);
			var i = -1;
			for (v in adecl)
			{
				++i;
				ret.push(macro $main[$v{cindex+i}] = $v);
			}
			cindex += matlen_real;
		}

		for (e in exprs)
		{
			switch(e.expr)
			{
				case EArrayDecl(adecl):
					processArr(adecl);
				default:
					if (ret.length == 0)
					{
						if (exprs.length != matlen)
							throw new Error('($name) Invalid number of arguments for $name definition: Expected $matlen; Got ${exprs.length}', e.pos);
						var i = -1;
						for (e in exprs)
						{
							++i;
							ret.push(macro $main[$v{i}] = $e);
						}
						break;
					} else {
						throw new Error('Unsupported expression', e.pos);
					}

			}
		}

		var decl = null;
		if (ret.length == matlen)
		{
			//is not array
		}

	}
// #end
}

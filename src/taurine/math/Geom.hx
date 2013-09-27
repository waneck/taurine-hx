package taurine.math;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

/**
	Provides static tools to make vector / matrix manipulation easier

	Recommended use:
	`import taurine.math.Geom.*`
**/
class Geom
{

	/**
		Easily create or convert a mat2d from the following expressions:
			*	6 Float elements - representing a,b,c,d,tx,ty
				*returns a Mat2D*
			*	Constant array elements - each containing 6 Float elements
				*returns a Mat2DArray. If only one array of elements is passed, returns a Mat2D*
		When using the constant array elements format, it is possible to get their respective indices by
		using the assign (`=`) operator:

		```
			var mat1,mat2;
			var arrmat = mat2d(
				mat1 = [1,1,
								1,1,
								1,1],
				mat2 = [2,2,
								2,2,
								2,2]
			);
			trace(arrmat.val(mat1,0)); //1
			trace(arrmat.val(mat2,0)); //2
		```
	**/
	macro public static function mat2d(exprs:Array<Expr>):Expr
	{
		var ret = mat2d_internal(exprs);
		// trace(haxe.macro.ExprTools.toString(ret));
		return ret;
	}

	/**
		Easily create or convert a vec2 from the following expressions:
			* 2 float elements - representing x,y
				*returns a Vec2*
			* Constant array of elements - each containing 6 Float elements
				*returns a Vec2Array. If only one array is passed, returns a Vec2*
		Supports the assign (`=`) operator (@see taurine.math.Geom.mat2d)
		(todo): convert from vec3, vec4; maybe even from mat[x]
	**/
	macro public static function vec2(exprs:Array<Expr>):Expr
	{
		return internal_create(2,2,"Vec2",exprs);
	}

	/**
		@see vec2
	**/
	macro public static function vec3(exprs:Array<Expr>):Expr
	{
		return internal_create(3,4,"Vec3",exprs);
	}

	/**
		@see vec2
	**/
	macro public static function vec4(exprs:Array<Expr>):Expr
	{
		return internal_create(4,4,"Vec4",exprs);
	}

	/**
		@see vec2
	**/
	macro public static function quat(exprs:Array<Expr>):Expr
	{
		return internal_create(4,4,"Quat",exprs);
	}

	/**
		Easily creates a Vec2, Vec3 or Vec4 - depending on the amount of elements passed
	**/
	macro public static function vec(exprs:Array<Expr>):Expr
	{
		switch(exprs.length)
		{
			case 2:
				return internal_create(2,2,"Vec2",exprs,false);
			case 3:
				return internal_create(3,4,"Vec3",exprs,false);
			case 4:
				return internal_create(4,4,"Vec4",exprs,false);
			case len:
				return throw new Error('(vec) Invalid number of arguments: $len', Context.currentPos());
		}
	}

	/**
		@see mat2d
	**/
	macro public static function mat3(exprs:Array<Expr>):Expr
	{
		return internal_create(9,9,"Mat3",exprs);
	}

	macro public static function mat4(exprs:Array<Expr>):Expr
	{
		return internal_create(16,16,"Mat4",exprs);
	}

#if macro
	public static function mat2d_internal(exprs:Array<Expr>):Expr
	{
		var matlen = 6, name = "Mat2D", matlen_real = 8;
		return internal_create(matlen, matlen_real, name, exprs);
	}

	private static function internal_create(matlen:Int, matlen_real:Int, name:String, exprs:Array<Expr>, allowArrays=true):Expr
	{
		var pos = Context.currentPos();
		if (exprs.length == 0)
			throw new Error('Invalid number of arguments for this call', pos);
		var ret = [], cindex = 0;
		var p = Context.getPosInfos(pos);
		var ename = new haxe.io.Path(p.file).file + "_" + p.min;
		var main = { expr: EConst(CIdent(ename)), pos: pos };

		function processArr(adecl:Array<Expr>, pos)
		{
			if (!allowArrays)
				throw new Error('($name) This function does not allow passing arrays as parameters', pos);
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
					processArr(adecl, e.pos);
					continue;
				case EBinop(OpAssign,e1,e2):
					var collected = [e1], idx = Std.int(cindex / matlen_real);
					function loop(e:Expr):Bool
					{
						switch(e.expr)
						{
							case EArrayDecl(adecl):
								processArr(adecl,e.pos);
								return true;
							case EBinop(OpAssign,e1,e2):
								collected.push(e1);
								return loop(e2);
							case ECheckType(e,_), EParenthesis(e):
								return loop(e);
							default:
								return false;
						}
					}
					if (loop(e2))
					{
						for (v in collected)
							ret.push(macro $v = $v{idx});
						continue;
					}
				default:
			}
			//if isn't an array
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

		var decl = null;
		if (ret.length == matlen)
		{
			//is not array
			ret.unshift(macro var $ename = taurine.math.$name.mk());
			decl = main;
		} else {
			var ename2 = ename + "tmp", size = Std.int(ret.length / matlen);
			decl = macro $i{ename2};
			var arrName = name + "Array";
			ret.unshift(macro var $ename2 = new taurine.math.$arrName($v{size}));
			ret.insert(1, macro var $ename = $decl.getData());
		}

		ret.push(decl);

		return { expr:EBlock(ret), pos:pos };
	}
#end
}

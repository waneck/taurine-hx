package taurine.math;
#if macro
import haxe.macro.Expr;
#end

/**
	This class provides Math-related compile-time utilities.
**/
class MacroMath
{
	public static inline var NaN = #if cpp Math.NaN #else 0 / 0 #end;
	public static inline var POSITIVE_INFINITY = #if cpp Math.POSITIVE_INFINITY #else 1. / 0 #end;
	public static inline var NEGATIVE_INFINITY = #if cpp Math.NEGATIVE_INFINITY #else -1. / 0 #end;

	macro public static function reduce(e:haxe.macro.Expr):haxe.macro.Expr
	{
		var ret = eval(e);
		if (Math.isNaN(ret))
			return macro taurine.math.MacroMath.NaN; //let it inline if possible
		else if (!Math.isFinite(ret))
			if (ret > 0)
				return macro Math.POSITIVE_INFINITY;
			else
				return macro Math.NEGATIVE_INFINITY;
		else
			return { expr: EConst(CFloat(ret + "")), pos: e.pos };
	}

#if macro
	public static function eval(e:Expr):Float
	{
		return switch(e.expr)
		{
			case EConst(CInt(s)):
				Std.parseInt(s);
			case EConst(CFloat(s)):
				Std.parseFloat(s);
			case ECall({expr: EField({expr: EConst(CIdent("Math")) }, field) }, args):
				var m = Reflect.field(Math, field);
				if (m == null) throw new Error('Unknown Math field: $field', e.pos);
				Reflect.callMethod(Math, m, args.map(eval));
			case EField({expr: EConst(CIdent("Math")) }, field):
				Reflect.field(Math, field);
			case EUnop(OpNeg, _, e1):
				-(eval(e1));
			case EUnop(OpNegBits, _, e1):
				~Std.int(eval(e1));
			case EBinop(op, e1, e2):
				var f1 = eval(e1), f2 = eval(e2);
				switch(op)
				{
					case OpXor:
						Std.int(f1) ^ Std.int(f2);
					case OpUShr:
						Std.int(f1) >>> Std.int(f2);
					case OpSub:
						f1 - f2;
					case OpShr:
						Std.int(f1) >> Std.int(f2);
					case OpShl:
						Std.int(f1) << Std.int(f2);
					case OpMult:
						f1 * f2;
					case OpMod:
						f1 % f2;
					case OpDiv:
						f1 / f2;
					case OpAdd:
						f1 + f2;
					case op:
						throw new Error('Invalid operation: $op', e.pos);
				}
			default: throw new Error('Unsupported evaluation for this expression', e.pos);
		};
	}
#end
}

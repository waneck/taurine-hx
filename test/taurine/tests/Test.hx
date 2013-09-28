package taurine.tests;
import taurine.tests.io.PathTests;
import taurine.tests.io.GlobTests;
import taurine.tests.io.UriTests;
import utest.Runner;
import utest.ui.Report;

/**
 * ...
 * @author waneck
 */
class Test
{

	static function main()
	{
		// trace(Math.PI * 100);
		// trace( Math.PI - Std.parseFloat(Math.PI + "") );
		// trace(3.141592653589793);
		teste1();
		trace(Math.PI + taurine.math.MacroMath.reduce(-Math.PI));
		trace(Math.PI + taurine.math.MacroMath.reduce(-Math.PI) == 0);
		trace(taurine.math.MacroMath.reduce(3.14));
		var runner = new Runner();

		runner.addCase(new PathTests());
		runner.addCase(new GlobTests());
		runner.addCase(new UriTests());
		runner.addCase(new taurine.tests.UInt8Tests());
		runner.addCase(new taurine.tests.mem.RawMemTests());
#if js
		runner.addCase(new taurine.tests.mem.RawMemTests.RawMemTestsBackwards());
		runner.addCase(new taurine.tests.mem.RawMemTests.RawMemTestsArray());
#end
		runner.addCase(new taurine.tests.math.MatrixTests());
		runner.addCase(new taurine.tests.math.QuatTests());

		// var report = Report.create(runner);
		var report = new utest.ui.text.PrintReport(runner);
		runner.run();

#if sys
		//Sys.exit(report.allOk() ? 0 : 1);
#end
	}

	private static function teste(a:Int)
	{
		trace(a);
	}

	@:extern inline private static function teste1(a:Int=-2)
	{
		teste(a);
	}

}

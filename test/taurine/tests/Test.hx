package taurine.tests;
import taurine.tests.io.PathTests;
import taurine.tests.io.GlobTests;
import taurine.tests.io.UriTests;
import utest.Runner;
import utest.ui.Report;
import taurine.math.Geom.*;

/**
 * ...
 * @author waneck
 */
class Test
{

	static function main()
	{
		// var v = new taurine.math.Vec2();
		// trace(taurine.math.Vec2.normalize);
		trace(mat2d(1,2,3,4,5,6));
		trace(mat2d([1,2,3,4,5,6]));
		trace(mat2d(
					[1,2,3,4,5,6],
					[1,0,
					 0,1,
					 0,0],
					[1,1,
					 2,2,
					 3,3]
					));
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

		// var report = Report.create(runner);
		var report = new utest.ui.text.PrintReport(runner);
		runner.run();

#if sys
		//Sys.exit(report.allOk() ? 0 : 1);
#end
	}

}

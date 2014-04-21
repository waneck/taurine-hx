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
		var runner = new Runner();

		runner.addCase(new taurine.tests.ds.LstTests());
// 		runner.addCase(new PathTests());
// 		runner.addCase(new GlobTests());
// 		runner.addCase(new UriTests());
// 		runner.addCase(new taurine.tests.UInt8Tests());
// 		runner.addCase(new taurine.tests.mem.RawMemTests());
// #if js
// 		runner.addCase(new taurine.tests.mem.RawMemTests.RawMemTestsBackwards());
// 		runner.addCase(new taurine.tests.mem.RawMemTests.RawMemTestsArray());
// #end
// 		runner.addCase(new taurine.tests.math.MatrixTests());
// 		runner.addCase(new taurine.tests.math.QuatTests());
		runner.addCase(new taurine.tests.react.ReactTests());

		// var report = Report.create(runner);
		var report = new utest.ui.text.PrintReport(runner);
		runner.run();

#if sys
		//Sys.exit(report.allOk() ? 0 : 1);
#end
	}
}

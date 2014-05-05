package taurine.tests;
import taurine.tests.io.PathTests;
import taurine.tests.io.GlobTests;
import taurine.tests.io.UriTests;
import utest.Runner;
import utest.ui.Report;
import taurine.io.Path;

/**
 * ...
 * @author waneck
 */
class Test
{

	static function main()
	{
		var runner = new Runner();

<<<<<<< HEAD
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
=======
		var p = Path.dot / "a" / "b" / "" / "c";
		trace(p);
		trace(p + "b");
		trace(p ^ "b");
		trace(p.normalize());
		trace(p.dirname());
		trace(p.dirname().dirname());
		trace(p.dirname().dirname().dirname());
		trace(p.dirname().dirname().dirname().dirname());
		trace(p.dirname().dirname().dirname().dirname().dirname());
>>>>>>> path general api - starting documentation

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
//
// 		// var report = Report.create(runner);
// 		var report = new utest.ui.text.PrintReport(runner);
// 		runner.run();

#if sys
		//Sys.exit(report.allOk() ? 0 : 1);
#end
	}

}

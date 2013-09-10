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

		runner.addCase(new PathTests());
		runner.addCase(new GlobTests());
		runner.addCase(new UriTests());

		var report = Report.create(runner);
		runner.run();

#if sys
		//Sys.exit(report.allOk() ? 0 : 1);
#end
	}

}

package taurine.tests;
import taurine.tests.io.PathTests;
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
		
		var report = Report.create(runner);
		runner.run();
		
#if sys
		//Sys.exit(report.allOk() ? 0 : 1);
#end
	}
	
}
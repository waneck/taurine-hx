package taurine.tests.io;
import taurine.io.Path;
import taurine.System;
import utest.Assert;

/**
 * ...
 * @author waneck
 */
class PathTests
{
	private var f:String;
	public function new()
	{
		f = #if sys Sys.getCwd() #else "/some/path/to/bin/" #end + "test.n";
	}

	public function testNames()
	{
		Assert.equals('test.n', Path.basename(f));
		Assert.equals('test', Path.basename(f, '.n'));
		Assert.equals('', Path.basename(''));
		Assert.equals('basename.ext', Path.basename('/dir/basename.ext'));
		Assert.equals('basename.ext', Path.basename('/basename.ext'));
		Assert.equals('basename.ext', Path.basename('basename.ext/'));
		Assert.equals('basename.ext', Path.basename('basename.ext//'));

		if (System.isWin)
		{
			// On Windows a backslash acts as a Path separator.
			Assert.equals(Path.basename('\\dir\\basename.ext'), 'basename.ext');
			Assert.equals(Path.basename('\\basename.ext'), 'basename.ext');
			Assert.equals(Path.basename('basename.ext'), 'basename.ext');
			Assert.equals(Path.basename('basename.ext\\'), 'basename.ext');
			Assert.equals(Path.basename('basename.ext\\\\'), 'basename.ext');
		} else {
			// On unix a backslash is just treated as any other character.
			Assert.equals(Path.basename('\\dir\\basename.ext'), '\\dir\\basename.ext');
			Assert.equals(Path.basename('\\basename.ext'), '\\basename.ext');
			Assert.equals(Path.basename('basename.ext'), 'basename.ext');
			Assert.equals(Path.basename('basename.ext\\'), 'basename.ext\\');
			Assert.equals(Path.basename('basename.ext\\\\'), 'basename.ext\\\\');
		}

		if (!System.isWin)
		{
			// POSIX filenames may include control characters
			// c.f. http://www.dwheeler.com/essays/fixing-unix-linux-filenames.html
			var controlCharFilename = 'Icon' + String.fromCharCode(13);
			Assert.equals(Path.basename('/a/b/' + controlCharFilename),controlCharFilename);
		}

		Assert.equals(Path.extname(f), '.n');

		Assert.equals(Path.dirname(f).substr(-3), 'bin');
		Assert.equals(Path.dirname('/a/b/'), '/a');
		Assert.equals(Path.dirname('/a/b'), '/a');
		Assert.equals(Path.dirname('/a'), '/');
		Assert.equals(Path.dirname(''), '.');
		Assert.equals(Path.dirname('/'), '/');
		Assert.equals(Path.dirname('////'), '/');

		if (System.isWin) {
		  Assert.equals(Path.dirname('c:\\'), 'c:\\');
		  Assert.equals(Path.dirname('c:\\foo'), 'c:\\');
		  Assert.equals(Path.dirname('c:\\foo\\'), 'c:\\');
		  Assert.equals(Path.dirname('c:\\foo\\bar'), 'c:\\foo');
		  Assert.equals(Path.dirname('c:\\foo\\bar\\'), 'c:\\foo');
		  Assert.equals(Path.dirname('c:\\foo\\bar\\baz'), 'c:\\foo\\bar');
		  Assert.equals(Path.dirname('\\'), '\\');
		  Assert.equals(Path.dirname('\\foo'), '\\');
		  Assert.equals(Path.dirname('\\foo\\'), '\\');
		  Assert.equals(Path.dirname('\\foo\\bar'), '\\foo');
		  Assert.equals(Path.dirname('\\foo\\bar\\'), '\\foo');
		  Assert.equals(Path.dirname('\\foo\\bar\\baz'), '\\foo\\bar');
		  Assert.equals(Path.dirname('c:'), 'c:');
		  Assert.equals(Path.dirname('c:foo'), 'c:');
		  Assert.equals(Path.dirname('c:foo\\'), 'c:');
		  Assert.equals(Path.dirname('c:foo\\bar'), 'c:foo');
		  Assert.equals(Path.dirname('c:foo\\bar\\'), 'c:foo');
		  Assert.equals(Path.dirname('c:foo\\bar\\baz'), 'c:foo\\bar');
		  Assert.equals(Path.dirname('\\\\unc\\share'), '\\\\unc\\share');
		  Assert.equals(Path.dirname('\\\\unc\\share\\foo'), '\\\\unc\\share\\');
		  Assert.equals(Path.dirname('\\\\unc\\share\\foo\\'), '\\\\unc\\share\\');
		  Assert.equals(Path.dirname('\\\\unc\\share\\foo\\bar'),
					   '\\\\unc\\share\\foo');
		  Assert.equals(Path.dirname('\\\\unc\\share\\foo\\bar\\'),
					   '\\\\unc\\share\\foo');
		  Assert.equals(Path.dirname('\\\\unc\\share\\foo\\bar\\baz'),
					   '\\\\unc\\share\\foo\\bar');
		}


		Assert.equals(Path.extname(''), '');
		Assert.equals(Path.extname('/Path/to/file'), '');
		Assert.equals(Path.extname('/Path/to/file.ext'), '.ext');
		Assert.equals(Path.extname('/Path.to/file.ext'), '.ext');
		Assert.equals(Path.extname('/Path.to/file'), '');
		Assert.equals(Path.extname('/Path.to/.file'), '');
		Assert.equals(Path.extname('/Path.to/.file.ext'), '.ext');
		Assert.equals(Path.extname('/Path/to/f.ext'), '.ext');
		Assert.equals(Path.extname('/Path/to/..ext'), '.ext');
		Assert.equals(Path.extname('file'), '');
		Assert.equals(Path.extname('file.ext'), '.ext');
		Assert.equals(Path.extname('.file'), '');
		Assert.equals(Path.extname('.file.ext'), '.ext');
		Assert.equals(Path.extname('/file'), '');
		Assert.equals(Path.extname('/file.ext'), '.ext');
		Assert.equals(Path.extname('/.file'), '');
		Assert.equals(Path.extname('/.file.ext'), '.ext');
		Assert.equals(Path.extname('.Path/file.ext'), '.ext');
		Assert.equals(Path.extname('file.ext.ext'), '.ext');
		Assert.equals(Path.extname('file.'), '.');
		Assert.equals(Path.extname('.'), '');
		Assert.equals(Path.extname('./'), '');
		Assert.equals(Path.extname('.file.ext'), '.ext');
		Assert.equals(Path.extname('.file'), '');
		Assert.equals(Path.extname('.file.'), '.');
		Assert.equals(Path.extname('.file..'), '.');
		Assert.equals(Path.extname('..'), '');
		Assert.equals(Path.extname('../'), '');
		Assert.equals(Path.extname('..file.ext'), '.ext');
		Assert.equals(Path.extname('..file'), '.file');
		Assert.equals(Path.extname('..file.'), '.');
		Assert.equals(Path.extname('..file..'), '.');
		Assert.equals(Path.extname('...'), '.');
		Assert.equals(Path.extname('...ext'), '.ext');
		Assert.equals(Path.extname('....'), '.');
		Assert.equals(Path.extname('file.ext/'), '.ext');
		Assert.equals(Path.extname('file.ext//'), '.ext');
		Assert.equals(Path.extname('file/'), '');
		Assert.equals(Path.extname('file//'), '');
		Assert.equals(Path.extname('file./'), '.');
		Assert.equals(Path.extname('file.//'), '.');

		if (System.isWin) {
		  // On windows, backspace is a Path separator.
		  Assert.equals(Path.extname('.\\'), '');
		  Assert.equals(Path.extname('..\\'), '');
		  Assert.equals(Path.extname('file.ext\\'), '.ext');
		  Assert.equals(Path.extname('file.ext\\\\'), '.ext');
		  Assert.equals(Path.extname('file\\'), '');
		  Assert.equals(Path.extname('file\\\\'), '');
		  Assert.equals(Path.extname('file.\\'), '.');
		  Assert.equals(Path.extname('file.\\\\'), '.');

		} else {
		  // On unix, backspace is a valid name component like any other character.
		  Assert.equals(Path.extname('.\\'), '');
		  Assert.equals(Path.extname('..\\'), '.\\');
		  Assert.equals(Path.extname('file.ext\\'), '.ext\\');
		  Assert.equals(Path.extname('file.ext\\\\'), '.ext\\\\');
		  Assert.equals(Path.extname('file\\'), '');
		  Assert.equals(Path.extname('file\\\\'), '');
		  Assert.equals(Path.extname('file.\\'), '.\\');
		  Assert.equals(Path.extname('file.\\\\'), '.\\\\');
		}
	}

	public function testPathJoin()
	{
		var joinTests:Array<Dynamic> =
		// arguments                     result
		[[['.', 'x/b', '..', '/b/c.js'], 'x/b/c.js'],
		 [['/.', 'x/b', '..', '/b/c.js'], '/x/b/c.js'],
		 [['/foo', '../../../bar'], '/bar'],
		 [['foo', '../../../bar'], '../../bar'],
		 [['foo/', '../../../bar'], '../../bar'],
		 [['foo/x', '../../../bar'], '../bar'],
		 [['foo/x', './bar'], 'foo/x/bar'],
		 [['foo/x/', './bar'], 'foo/x/bar'],
		 [['foo/x/', '.', 'bar'], 'foo/x/bar'],
		 [['./'], './'],
		 [['.', './'], './'],
		 [['.', '.', '.'], '.'],
		 [['.', './', '.'], '.'],
		 [['.', '/./', '.'], '.'],
		 [['.', '/////./', '.'], '.'],
		 [['.'], '.'],
		 [['', '.'], '.'],
		 [['', 'foo'], 'foo'],
		 [['foo', '/bar'], 'foo/bar'],
		 [['', '/foo'], '/foo'],
		 [['', '', '/foo'], '/foo'],
		 [['', '', 'foo'], 'foo'],
		 [['foo', ''], 'foo'],
		 [['foo/', ''], 'foo/'],
		 [['foo', '', '/bar'], 'foo/bar'],
		 [['./', '..', '/foo'], '../foo'],
		 [['./', '..', '..', '/foo'], '../../foo'],
		 [['.', '..', '..', '/foo'], '../../foo'],
		 [['', '..', '..', '/foo'], '../../foo'],
		 [['/'], '/'],
		 [['/', '.'], '/'],
		 [['/', '..'], '/'],
		 [['/', '..', '..'], '/'],
		 [[''], '.'],
		 [['', ''], '.'],
		 [[' /foo'], ' /foo'],
		 [[' ', 'foo'], ' /foo'],
		 [[' ', '.'], ' '],
		 [[' ', '/'], ' /'],
		 [[' ', ''], ' '],
		 [['/', 'foo'], '/foo'],
		 [['/', '/foo'], '/foo'],
		 [['/', '//foo'], '/foo'],
		 [['/', '', '/foo'], '/foo'],
		 [['', '/', 'foo'], '/foo'],
		 [['', '/', '/foo'], '/foo']
		];

		// Windows-specific join tests
		if (System.isWin) {
			joinTests = joinTests.concat(
			[// UNC Path expected
			 [['//foo/bar'], '//foo/bar/'],
			 [['\\/foo/bar'], '//foo/bar/'],
			 [['\\\\foo/bar'], '//foo/bar/'],
			 // UNC Path expected - server and share separate
			 [['//foo', 'bar'], '//foo/bar/'],
			 [['//foo/', 'bar'], '//foo/bar/'],
			 [['//foo', '/bar'], '//foo/bar/'],
			 // UNC Path expected - questionable
			 [['//foo', '', 'bar'], '//foo/bar/'],
			 [['//foo/', '', 'bar'], '//foo/bar/'],
			 [['//foo/', '', '/bar'], '//foo/bar/'],
			 // UNC Path expected - even more questionable
			 [['', '//foo', 'bar'], '//foo/bar/'],
			 [['', '//foo/', 'bar'], '//foo/bar/'],
			 [['', '//foo/', '/bar'], '//foo/bar/'],
			 // No UNC Path expected (no double slash in first component)
			 [['\\', 'foo/bar'], '/foo/bar'],
			 [['\\', '/foo/bar'], '/foo/bar'],
			 [['', '/', '/foo/bar'], '/foo/bar'],
			 // No UNC Path expected (no non-slashes in first component - questionable)
			 [['//', 'foo/bar'], '/foo/bar'],
			 [['//', '/foo/bar'], '/foo/bar'],
			 [['\\\\', '/', '/foo/bar'], '/foo/bar'],
			 [['//'], '/'],
			 // No UNC Path expected (share name missing - questionable).
			 [['//foo'], '/foo'],
			 [['//foo/'], '/foo/'],
			 [['//foo', '/'], '/foo/'],
			 [['//foo', '', '/'], '/foo/'],
			 // No UNC Path expected (too many leading slashes - questionable)
			 [['///foo/bar'], '/foo/bar'],
			 [['////foo', 'bar'], '/foo/bar'],
			 [['\\\\\\/foo/bar'], '/foo/bar'],
			 // Drive-relative vs drive-absolute Paths. This merely describes the
			 // status quo, rather than being obviously right
			 [['c:'], 'c:.'],
			 [['c:.'], 'c:.'],
			 [['c:', ''], 'c:.'],
			 [['', 'c:'], 'c:.'],
			 [['c:.', '/'], 'c:./'],
			 [['c:.', 'file'], 'c:file'],
			 [['c:', '/'], 'c:/'],
			 [['c:', 'file'], 'c:/file']
			]);
		}

		for (test in joinTests)
		{
			var actual = Path.join(test[0]);
			var expected = System.isWin ? StringTools.replace(test[1], '/', '\\') : test[1];
			var message = 'Path.join(' + test[0].join(',') + ')' +
                '\n  expect=' + expected +
                '\n  actual=' + actual;
			Assert.equals(actual, expected, message);
			if (actual != expected)
				throw "";
		}

	}

	public function testNormalize()
	{
		// Path normalize tests
		if (System.isWin) {
		  Assert.equals(Path.normalize('./fixtures///b/../b/c.js'),
					   'fixtures\\b\\c.js');
		  Assert.equals(Path.normalize('/foo/../../../bar'), '\\bar');
		  Assert.equals(Path.normalize('a//b//../b'), 'a\\b');
		  Assert.equals(Path.normalize('a//b//./c'), 'a\\b\\c');
		  Assert.equals(Path.normalize('a//b//.'), 'a\\b');
		  Assert.equals(Path.normalize('//server/share/dir/file.ext'),
					   '\\\\server\\share\\dir\\file.ext');
		} else {
		  Assert.equals(Path.normalize('./fixtures///b/../b/c.js'),
					   'fixtures/b/c.js');
		  Assert.equals(Path.normalize('/foo/../../../bar'), '/bar');
		  Assert.equals(Path.normalize('a//b//../b'), 'a/b');
		  Assert.equals(Path.normalize('a//b//./c'), 'a/b/c');
		  Assert.equals(Path.normalize('a//b//.'), 'a/b');
		}
	}

	public function testResolve()
	{
		var resolveTests:Array<Dynamic>;
		// Path.resolve tests
		if (System.isWin) {
		  // windows
		  resolveTests =
			  // arguments                                    result
			  [[['c:/blah\\blah', 'd:/games', 'c:../a'], 'c:\\blah\\a'],
			   [['c:/ignore', 'd:\\a/b\\c/d', '\\e.exe'], 'd:\\e.exe'],
			   [['c:/ignore', 'c:/some/file'], 'c:\\some\\file'],
			   [['d:/ignore', 'd:some/dir//'], 'd:\\ignore\\some\\dir'],
#if sys
			   [['.'], System.cwd().substr(0,-1)],
#end
			   [['//server/share', '..', 'relative\\'], '\\\\server\\share\\relative'],
			   [['c:/', '//'], 'c:\\'],
			   [['c:/', '//dir'], 'c:\\dir'],
			   [['c:/', '//server/share'], '\\\\server\\share\\'],
			   [['c:/', '//server//share'], '\\\\server\\share\\'],
			   [['c:/', '///some//dir'], 'c:\\some\\dir']
			  ];
		} else {
		  // Posix
		  resolveTests =
			  // arguments                                    result
			  [[['/var/lib', '../', 'file/'], '/var/file'],
			   [['/var/lib', '/../', 'file/'], '/file'],
#if sys
			   [['a/b/c/', '../../..'], System.cwd().substr(0,-1)],
			   [['.'], System.cwd().substr(0,-1)],
#end
			   [['/some/dir', '.', '/absolute/'], '/absolute']];
		}
		for (test in resolveTests)
		{
			var actual = Path.resolve(test[0]);
			var expected = test[1];
			var message = 'Path.resolve(' + test[0].join(',') + ')' +
						'\n  expect=' + expected +
						'\n  actual=' + actual;

			Assert.equals(expected, actual, message);
			if (expected != actual)
				throw "";
		}
	}

	public function testIsAbsolute()
	{
		if (System.isWin) {
		  Assert.equals(Path.isAbsolute('//server/file'), true);
		  Assert.equals(Path.isAbsolute('\\\\server\\file'), true);
		  Assert.equals(Path.isAbsolute('C:/Users/'), true);
		  Assert.equals(Path.isAbsolute('C:\\Users\\'), true);
		  Assert.equals(Path.isAbsolute('C:cwd/another'), false);
		  Assert.equals(Path.isAbsolute('C:cwd\\another'), false);
		  Assert.equals(Path.isAbsolute('directory/directory'), false);
		  Assert.equals(Path.isAbsolute('directory\\directory'), false);
		} else {
		  Assert.equals(Path.isAbsolute('/home/foo'), true);
		  Assert.equals(Path.isAbsolute('/home/foo/..'), true);
		  Assert.equals(Path.isAbsolute('bar/'), false);
		  Assert.equals(Path.isAbsolute('./baz'), false);
		}
	}

	public function testRelative()
	{
		var relativeTests = if (System.isWin) {
			// windows
			  // arguments                     result
			  [['c:/blah\\blah', 'd:/games', 'd:\\games'],
			   ['c:/aaaa/bbbb', 'c:/aaaa', '..'],
			   ['c:/aaaa/bbbb', 'c:/cccc', '..\\..\\cccc'],
			   ['c:/aaaa/bbbb', 'c:/aaaa/bbbb', ''],
			   ['c:/aaaa/bbbb', 'c:/aaaa/cccc', '..\\cccc'],
			   ['c:/aaaa/', 'c:/aaaa/cccc', 'cccc'],
			   ['c:/', 'c:\\aaaa\\bbbb', 'aaaa\\bbbb'],
			   ['c:/aaaa/bbbb', 'd:\\', 'd:\\']];
		} else {
			// posix
			  // arguments                    result
			  [['/var/lib', '/var', '..'],
			   ['/var/lib', '/bin', '../../bin'],
			   ['/var/lib', '/var/lib', ''],
			   ['/var/lib', '/var/apache', '../apache'],
			   ['/var/', '/var/lib', 'lib'],
			   ['/', '/var/lib', 'var/lib']];
		}
		for (test in relativeTests)
		{
			var actual = Path.relative(test[0], test[1]);
			var expected = test[2];
			var message = 'Path.relative(' +
					test.slice(0, 2).join(',') +
					')' +
					'\n  expect=' + (expected) +
					'\n  actual=' + (actual);
			Assert.equals(expected, actual, message);
		}
	}
}

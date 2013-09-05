package taurine.io;

/**
	Provides pathname expansion syntax to Haxe. Native platform-dependent path separators are accepted.
	It follows an extended UNIX syntax:

	- `*` - Matches any file. Can be restricted by other values in the glob. `*` will match all files;
	`c*` will match all files beginning with c. Note that `*` **will** match Unix-like hidden files (dotfiles),
	unless the `NoDot` flag is enabled.

	- `**` - Matches directories recursively.

	- `?` - Matches any one character. Equivalent to `.` on `EReg`

	- `[set]` - Matches any one character in `set`. Behaves exactly like character sets in `EReg`, including set negation(`[^a-z]`).
	Supports a restricted ([^\\\/\(\)]) input inside

	Unless the `NoExt` flag is set, the following `extglob` syntax is also supported:
	- `?(pattern-list)` - Matches zero or one occurrence of the given patterns.

	- `*(pattern-list)` - Matches zero or more occurrences of the given patterns

	- `+(pattern-list)` - Matches one or more occurrences of the given patterns

	- `@(pattern-list)` - Matches one of the given patterns

	- `!(pattern-list)` - Matches anything except one of the given patterns.
	Note that `!` may also be used without the parenthesis, iff it's the first character in a path part.
	That is, `somedir/!*.hx` will match any file in the `somedir` directory that doesn't end with `.hx`. However,
	`somedir/myfile!*.hx` is an invalid glob and will result in an error when compiling it, unless the `NoExt` flag is used.

	- `~(regex-pattern)` - Matches an actual regex pattern. For help on regex syntax, consult Haxe EReg manual.

	Pattern lists should be separated with a `|` character.

## Thread-safety
	This object is thread-safe

## Path separators
	In order to allow both windows and posix paths to be built using `Glob`,
	both `/` and `\` path separators may be used, and compile correctly into either systems.

## Escaping
	Because of the windows path separator support, escaping characters should be done with a backtick (`` ` ``) character.
	If POSIX compliance is needed, the `Posix` flag can be used.

## Security
	It's not considered safe to use GlobPath as a sandbox for untrusted input
**/
class GlobPath
{
	public var flags(default, null):haxe.EnumFlags<GlobFlags>;
	public var pattern(default, null):String;
	private var regex:EReg;

	/**
		Creates a new GlobPath object and compiles the pattern. May throw a GlobError object
	**/
	public function new(pattern:String, ?flags:Array<GlobFlags>)
	{
		this.flags = new haxe.EnumFlags(0);
		if (flags != null) for (f in flags)
			this.flags.set(f);
		this.pattern = pattern;

		this.regex = compile(pattern, this.flags);
	}

	/**
		Tells whether the `path` parameter matches a valid Glob path
	**/
	public inline function match(path:String):Bool
	{
		return regex.match(path);
	}

	/**
		Tells whether the `path` parameter matches a valid Glob path.
		The `path` parameter is expected to be already in a normalized form
	**/
	public inline function unsafeMatch(normalizedPath:String):Bool
	{
		return regex.match(normalizedPath);
	}

	@:keep public function toString()
	{
		return pattern;
	}

	/**
		Compiles a pattern into a Haxe EReg. May throw a GlobError object
	**/
	static function compile(pattern:String, flags:haxe.EnumFlags<GlobFlags>):EReg
	{
		var extraSep = '\\'.code, escapeChar = '`'.code, posix = flags.has(Posix), ext = !flags.has(NoExt), nodot = flags.has(NoDot);
		var pathSep = "[\\/\\\\]+", notPathSep = "^\\/\\\\";
		if (posix)
		{
			extraSep = '/'.code;
			escapeChar = '\\'.code;
			pathSep = "[\\/]+";
			notPathSep = "^\\/";
		}

		if (nodot)
			notPathSep = '[$notPathSep\\.]+[$notPathSep]*';
		else
			notPathSep = '[$notPathSep]+';

		var pat = new StringBuf();
		pat.add("^"); //match from beginning
		var i = -1, len = pattern.length, beginPath = true, onParenEnd = [], onPartEnd = null, openLiterals = [], curLiteral:Null<Int> = null;
		var beginPathStack = [];
		while(++i < len)
		{
			var chr = StringTools.fastCodeAt(pattern, i), wasBeginPath = beginPath;
			beginPath = false;
			switch(chr)
			{
			case '/'.code, '\\'.code if (curLiteral != '['.code && (!posix || chr == '/'.code)):
				//check part end
				if (openLiterals.length == 0 && onPartEnd != null) //openLiterals only implemented for top-level path parts
				{
					pat.add(onPartEnd);
					onPartEnd = null;
				}
				//path separator
				pat.add(pathSep);
				beginPath = true;
			case '*'.code:
				//lookahead for '*(' or '**'
				if (i + 1 < len) switch(StringTools.fastCodeAt(pattern, i+1))
				{
				case '('.code if (ext):
					i++;
					//matches zero or more occurrences of the given patterns
					pat.add('(?:');
					onParenEnd.push(')*');
					openLiterals.push(curLiteral = '('.code);
					beginPathStack.push(wasBeginPath);
					continue;
				case '*'.code:
					i++;
					//matches directories recursively
					pat.add('.*');
					continue;
				case chr:
					if (wasBeginPath)
					{
						//if we're in the beginning of a path, check if next character further restricts the pattern
						//if not, this pattern may not be null
						switch(chr)
						{
							case '|'.code, ')'.code if (ext):
							case '/'.code:
							case '\\'.code if (!posix):
							case _:
								//this pattern may not be null
								pat.add(notPathSep);
								continue;
						}
					}
				} else if (wasBeginPath) {
					//this.pattern may not be null
					pat.add(notPathSep);
					continue;
				}
				//any character but path separator
				pat.add("(?:");
				pat.add(notPathSep);
				pat.add("|)");
			case '?'.code:
				//lookahead for '?('
				if (ext && i + 1 < len) switch(StringTools.fastCodeAt(pattern, i+1))
				{
				case '('.code:
					pat.add("(?:");
					onParenEnd.push(")?");
					openLiterals.push(curLiteral = '('.code);
					beginPathStack.push(wasBeginPath);
					continue;
				case _:
				}
				if (wasBeginPath && nodot)
					pat.add('[^\\.]');
				else
					pat.add('.');

			//[set] handling
			//reject special characters if inside []
			// case '\\'.code, '/'.code, '('.code, ')'.code, '`'.code, '+'.code, '!'.code if(curLiteral == '['.code):
				//check if next is a escaped
				// pat.addChar(chr);
			case '-'.code if (curLiteral == '['.code):
				pat.addChar(chr);
			case '['.code:
				//apparently, a single '[' is a valid glob
				if (i == 0 && len == 1)
				{
					pat.add("\\[");
					break;
				}

				pat.addChar(chr);
				openLiterals.push(curLiteral = '['.code);

				//[]] is considered [\\]] on POSIX
				if (i + 1 < len) switch(StringTools.fastCodeAt(pattern, i+1))
				{
					case '['.code:
						i++;
						pat.addChar('['.code);
					case ']'.code:
						i++;
						pat.addChar(']'.code);
					case '^'.code:
						i++;
						pat.addChar('^'.code);
						if (wasBeginPath && nodot)
							pat.add('\\.');
					case _:
				}
			case ']'.code:
				if (curLiteral != '['.code)
					throw GlobError(pattern, i, 'Unmatched ]');
				openLiterals.pop();
				curLiteral = openLiterals[openLiterals.length-1];
				pat.addChar(chr);

			//!
			case '!'.code if(ext):
				//we either have !(), or ! at the beginning of a slash
				if (i + 1 < len) switch(StringTools.fastCodeAt(pattern, i+1))
				{
					case '('.code:
						i++;
						pat.add("(?!");
						onParenEnd.push(")");
						openLiterals.push(curLiteral = '('.code);
						beginPathStack.push(wasBeginPath);
						continue;
					case _:
				}

				if (!wasBeginPath || openLiterals.length != 0 || onPartEnd != null)
					throw InvalidExclamationPat(pattern, i);
				pat.add("(?!");
				onPartEnd = ")";

			//+(), @()
			case '+'.code, '@'.code if (ext && i + 1 < len && StringTools.fastCodeAt(pattern, i+1) == '('.code):
				i++;
				pat.add("(?:");
				onParenEnd.push(")" + (chr == '+'.code ? "+" : ""));
				openLiterals.push(curLiteral = '('.code);
				beginPathStack.push(wasBeginPath);

			case '|'.code if(ext):
				if (curLiteral != '('.code)
					throw GlobError(pattern, i, "Unexpected |");
				pat.addChar(chr);
				beginPath = beginPathStack[beginPathStack.length-1];

			case ')'.code if(ext):
				if (curLiteral != '('.code)
					throw GlobError(pattern, i, "Unmatched )");
				var p = onParenEnd.pop();
				if (p == null) throw "assert";
				pat.add(p);
				openLiterals.pop();
				curLiteral = openLiterals[openLiterals.length-1];
				beginPath = beginPathStack.pop();

			//escape
			case '`'.code, '\\'.code if(escapeChar == chr):
				if (i + 1 >= len)
				{
					// throw GlobError(pattern,i, "Invalid escape char");
					//edit: it seems that glob considers this acceptable
					if (chr == '\\'.code)
						pat.addChar(chr);
					pat.addChar(chr);
					break;
				}
				i++;
				//escape all possible regex special chars
				switch(chr = StringTools.fastCodeAt(pattern, i))
				{
					case '+'.code, '*'.code, '-'.code, '\\'.code, '/'.code, '['.code, ']'.code, '('.code, ')'.code, '?'.code, '^'.code, '.'.code, '$'.code, '|'.code, '{'.code, '}'.code:
						pat.addChar('\\'.code);
					case _:
				}
				pat.addChar(chr);
			case '('.code if(ext):
				throw GlobError(pattern,i, "Invalid '(' without !,+,@,?,*");
			case _:
				//escape all possible regex special chars
				switch(chr)
				{
					case '+'.code, '*'.code, '-'.code, '\\'.code, '/'.code, '['.code, ']'.code, '('.code, ')'.code, '?'.code, '^'.code, '.'.code, '$'.code, '|'.code, '{'.code, '}'.code:
						pat.addChar('\\'.code);
					case _:
				}
				pat.addChar(chr);
			}
		}

		if (openLiterals.length != 0)
			throw GlobError(pattern, pattern.length, 'Unterminated literals: ${openLiterals.map(String.fromCharCode).join(",")}');
		pat.add("(?!.)"); //only exact match
		trace(pat);

		return new EReg(pat.toString(), flags.has(NoCase) ? "i" : "");
	}

}

enum GlobFlags
{
	/**
		Doesn't match dotfiles unless the pattern explicitly includes it
	**/
	NoDot;
	/**
		Disables `extglob` extensions
	**/
	NoExt;
	/**
		Case insenstive match
	**/
	NoCase;
	/**
		Forces POSIX compliance. Will drop `\` support for path separators, and make it behave like a escape character
	**/
	Posix;
}

enum GlobError
{
	/**
		General glob error. A message is included to better describe the issue
	**/
	GlobError(pattern:String, charPos:Int, msg:String);
	/**
		General parsing error
	**/
	InvalidPat(pattern:String, charPos:Int);
	/**
		Thrown when the NoExt flag is not set, and an invalid `!` is encountered during parsing
	**/
	InvalidExclamationPat(pattern:String, charPos:Int);
}

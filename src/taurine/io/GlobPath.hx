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

		var c = compile(pattern, this.flags);
		this.regex = c.exact;
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

	static function normalizePosix(pattern:String)
	{
		//posix allows some wacky unescaped expressions. Let's escape them before we start
		var nBr = 0, nPt = 0, lastBr = -1, lastPt = -1, escape = false, add = 0, pat = new StringBuf(), last = -1;
		for (i in 0...pattern.length)
		{
			var chr = StringTools.fastCodeAt(pattern, i), lst = last;
			last = chr;
			if (escape)
			{
				pat.addChar(chr);
				escape = false;
				continue;
			}

			switch(chr)
			{
			case '\\'.code:
				escape = true;
			case '('.code:
				nPt++;
				lastPt = i + add;
			case ')'.code:
				if (--nPt < 0)
				{
					nPt = 0;
					//escaped
					pat.add("\\)");
					add++;
					continue;
				}
			case '|'.code:
				if (nPt == 0)
				{
					pat.add("\\|");
					add++;
					continue;
				}
			case '['.code:
				if (nBr > 0)
				{
					pat.add("\\[");
					last = -1;
					add++;
					continue;
				} else {
					nBr++;
					lastBr = i + add;
				}
			case ']'.code:
				if (lst == '['.code)
				{
					//act as if it were escaped
					pat.add("\\]");
					add++;
					continue;
				} else if (--nBr < 0) {
					nBr = 0;
					//escaped
					pat.add("\\]");
					add++;
					continue;
				}
			case _:
			}
			pat.addChar(chr);
		}

		var pat = pat.toString();
		if (nBr != 0) //open bracket
		{
			pat = pat.substr(0,lastBr) + "\\" + pat.substr(lastBr);
			if (lastPt > lastBr)
				lastPt++;
		}

		if (nPt != 0) //open paren
		{
			var right = pat.substr(lastPt);
			var buf = new StringBuf();
			buf.add(pat.substr(0,lastPt));
			buf.add("\\");
			var escaped = false;
			//escape any non-escaped |
			for(i in 0...right.length)
			{
				var chr = StringTools.fastCodeAt(right,i), wasEscaped = escaped;
				escaped = false;
				switch(chr)
				{
					case '\\'.code if(!wasEscaped):
						escaped = true;
					case '|'.code:
						if (wasEscaped)
							buf.add("\\");
						buf.add("\\|");
						continue;
				}
				buf.addChar(chr);
			}

			pat = buf.toString();
		}

		// trace(pat,pattern);
		return pat;
	}

	/**
		Compiles a pattern into a Haxe EReg. May throw a GlobError object
	**/
	static function compile(pattern:String, flags:haxe.EnumFlags<GlobFlags>):{ exact: EReg, partials: Array<GlobPart> }
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

		var notPathSepStart =
			if (nodot)
				'[$notPathSep\\.]+[$notPathSep]*';
			else
				'[$notPathSep]+';

		if (posix)
		{
			pattern = normalizePosix(pattern);
		}

		var pat = new StringBuf();
		// pat.add("^"); //match from beginning
		var i = -1, len = pattern.length, beginPath = true, onParenEnd = [], inNegate = false, openLiterals = [], curLiteral:Null<Int> = null;
		var rawPartials = [], partials = [], hasConcrete = false, hasPattern = false, isWildcard = false, isRecursive = false;
		var beginPathStack = [];
		while(++i < len)
		{
			var chr = StringTools.fastCodeAt(pattern, i), wasBeginPath = beginPath;
			beginPath = false;
			switch(chr)
			{
			case '/'.code, '\\'.code if (curLiteral != '['.code && (!posix || chr == '/'.code)):
				//check part end
				if (openLiterals.length == 0) //openLiterals only implemented for top-level path parts
				{
					if (inNegate)
					{
						pat.add(").*"); //match anything but this
						inNegate = false;
					}
					//complete current partial
					var s = pat.toString();
					pat = new StringBuf();
					rawPartials.push(s);
					var part = switch [hasConcrete, hasPattern, isWildcard]
					{
					case [true,false,false]:
						Exact(s, flags.has(NoCase));
					case [false,false,true]:
						Any(isRecursive);
					default:
						Regex(new EReg("^" + s + "$", flags.has(NoCase) ? "i" : ""), isRecursive);
					};
					partials.push(part);

					hasConcrete = hasPattern = isWildcard = isRecursive = false;
				} else {
					//path separator
					pat.add(pathSep);
				}
				beginPath = true;
			case '*'.code:
				//lookahead for '*(' or '**'
				if (i + 1 < len) switch(StringTools.fastCodeAt(pattern, i+1))
				{
				case '('.code if (ext):
					i++;
					hasPattern = true;
					//matches zero or more occurrences of the given patterns
					pat.add('(?:');
					onParenEnd.push(')*');
					openLiterals.push(curLiteral = '('.code);
					beginPathStack.push(wasBeginPath);
					continue;
				case '*'.code:
					i++;
					isWildcard = true; isRecursive = true;
					//matches directories recursively
					if (nodot) {
						if (wasBeginPath)
						{
							//[ [any char but path sep or .] + [any char but path sep] ]
							pat.add('(?:(?:[^$notPathSep\\.][^$notPathSep]*)(?:$pathSep|))*');
						} else {
							pat.add('(?:(?:[^$notPathSep]*)(?:$pathSep(?:[^$notPathSep\\.]|)|))*');
						}
					// } else { //allow first globstar **/x to match 'x' files
					} else {
						pat.add('.*');
					}
					continue;
				case chr:
					isWildcard = true;
					if (wasBeginPath)
					{
						//if we're in the beginning of a path, check if next character further restricts the pattern
						//if not, this pattern cannot be matched to empty
						switch(chr)
						{
							case '|'.code, ')'.code if (ext):
							case '/'.code:
							case '\\'.code if (!posix):
							case _:
								//this pattern cannot be matched to empty
								pat.add(notPathSepStart);
								continue;
						}
					}
				} else if (wasBeginPath) {
					//this.pattern may not be null
					pat.add(notPathSepStart);
					continue;
				}
				isWildcard = true;
				//any character but path separator
				pat.add("(?:");
				pat.add(notPathSepStart);
				pat.add("|)");
			case '?'.code:
				hasPattern = true;
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
				hasPattern = true;
				if (i + 1 < len) switch(StringTools.fastCodeAt(pattern, i+1))
				{
					case ']'.code:
						i++;
						continue;
					case '^'.code, '!'.code:
						pat.addChar(chr);
						openLiterals.push(curLiteral = '['.code);

						i++;
						pat.addChar('^'.code);
						if (wasBeginPath && nodot)
							pat.add('\\.');
						continue;
					case _:
				}
				pat.addChar(chr);
				openLiterals.push(curLiteral = '['.code);

			case ']'.code:
				if (curLiteral != '['.code)
					throw GlobError(pattern, i, 'Unmatched ]');
				openLiterals.pop();
				curLiteral = openLiterals[openLiterals.length-1];
				pat.addChar(chr);

			//!
			case '!'.code if(ext):
				hasPattern = true;
				//we either have !(), or ! at the beginning of a slash
				if (i + 1 < len) switch(StringTools.fastCodeAt(pattern, i+1))
				{
					case '('.code:
						i++;
						pat.add("(?!");
						onParenEnd.push(").*");
						openLiterals.push(curLiteral = '('.code);
						beginPathStack.push(wasBeginPath);
						continue;
					case _:
				}

				if (!wasBeginPath || openLiterals.length != 0 || inNegate)
					throw InvalidExclamationPat(pattern, i);
				pat.add("(?!");
				inNegate = true;

			//+(), @()
			case '+'.code, '@'.code if (ext && i + 1 < len && StringTools.fastCodeAt(pattern, i+1) == '('.code):
				i++;
				hasPattern = true;
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
					if (!posix)
						throw GlobError(pattern,i, "Invalid escape char");
					hasConcrete = true;
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
				hasConcrete = true;
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

		if (inNegate)
		{
			pat.add(").*"); //match anything but this
		}

		if (openLiterals.length != 0)
		{
			throw GlobError(pattern, pattern.length, 'Unterminated literals: ${openLiterals.map(String.fromCharCode).join(",")}');
		}
		// pat.add("$"); //only exact match

		var s = pat.toString();
		rawPartials.push(s);
		var part = switch [hasConcrete, hasPattern, isWildcard]
		{
		case [true,false,false]:
			Exact(s, flags.has(NoCase));
		case [false,false,true]:
			Any(isRecursive);
		default:
			Regex(new EReg("^" + s + "$", flags.has(NoCase) ? "i" : ""), isRecursive);
		};
		partials.push(part);

		var pat = "^" + rawPartials.join(pathSep) + "$";

		// trace(pat);

		return { exact : new EReg(pat, flags.has(NoCase) ? "i" : ""), partials: partials };
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

enum GlobPart
{
	Exact(s:String, caseSensitive:Bool); //matches exactly
	Any(recursive:Bool); //* and **
	Regex(r:EReg, recursive:Bool); //is recursive if has globstar (**)
}

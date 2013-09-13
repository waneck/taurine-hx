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
	It's not considered safe to use Glob as a sandbox for untrusted input
**/
class Glob
{
	public var flags(default, null):haxe.EnumFlags<GlobFlags>;
	public var pattern(default, null):String;
	private var regex:EReg;
	private var partials:Array<GlobPart>;

	/**
		Creates a new Glob object and compiles the pattern. May throw a GlobError object
	**/
	public function new(pattern:String, ?flags:Array<GlobFlags>)
	{
		this.flags = new haxe.EnumFlags(0);
		if (flags != null) for (f in flags)
			this.flags.set(f);
		this.pattern = pattern;

		var c = compile(pattern, this.flags);
		this.regex = c.exact;
		this.partials = c.partials;
	}

	/**
		Tells whether the `path` parameter matches a valid Glob path
	**/
	public inline function exact(path:String):Bool
	{
		return regex.match(Path.normalize(path));
	}

	/**
		Tells whether the `path` parameter matches a valid Glob path.
		The `path` parameter is expected to be already in a normalized form
	**/
	public inline function unsafeExact(normalizedPath:String):Bool
	{
		return regex.match(normalizedPath);
	}

	/**
		Tells whether the `path` parameter can be a valid subpath of this pattern.
		May be used to eagerly rule out unmatched directories from search
	**/
	public inline function partial(path:String):Bool
	{
		return unsafePartial(Path.normalize(path));
	}

	/**
		Tells whether the normalized `path` parameter can be a valid subpath of this pattern.
		May be used to eagerly rule out unmatched directories from search.
		The `path` parameter is expected to be already in a normalized form
	**/
	public inline function unsafePartial(normalizedPath:String):Bool
	{
		return unsafeMatch(normalizedPath).matches;
	}

	/**
		Tells if either the normalized `path` matches - either partially or exactly, the specified pattern.
		A `GlobMatch` object is returned, so it can be later checked if there was a match, and if it was partial or exact.
	 */
	public inline function match(path:String):GlobMatch
	{
		return unsafeMatch(Path.normalize(path));
	}

	/**
		Tells if either the normalized `path` matches - either partially or exactly, the specified pattern.
		A `GlobMatch` object is returned, so it can be later checked if there was a match, and if it was partial or exact.
		The `path` parameter is expected to be already in a normalized form
	 */
	public function unsafeMatch(normalizedPath:String):GlobMatch
	{
		var nodot = flags.has(NoDot);
		var path = flags.has(Posix) ? normalizedPath.split("/") : ~/[\\\/]/g.split(normalizedPath);
		var li = 0, ll = partials.length, i = 0, len = path.length, lastAnyRec = false;
		while(i < len)
		{
			var cur = path[i++];
			if (li >= ll) //we have reached the last path delimiter; this is not a valid match
				if (i == len && cur == "")
					return GlobMatch.Exact;
				else
					return GlobMatch.NoMatch;

			var willReturn = false, retval = false;
			switch(partials[li++])
			{
				case PExact(s,false):
					if (cur != s)
					{
						return GlobMatch.NoMatch;
					}
				case PExact(s,true):
					if (cur.toLowerCase() != s.toLowerCase())
						return GlobMatch.NoMatch;
				case PAny(false):
					if (nodot && cur.charCodeAt(0) == '.'.code)
						return GlobMatch.NoMatch;
					//always matches
				case PRegex(r, false,s):
					if (!r.match(cur))
					{
						return GlobMatch.NoMatch;
					}
				case PAny(true):
					var found = false;
					//if (i == 1)
						//i = 0;
					i--;
					for (j in li...ll)
					{
						switch(partials[j])
						{
							case PRegex(r,_,_):
								li = j; found = true;
								for (k in i...len)
								{
									if (r.match(path[k]))
									{
										i = k;
										break;
									} else if (nodot && path[k].charCodeAt(0) == '.'.code) {
										return GlobMatch.NoMatch;
									}
								}
								break;
							case PExact(s,true):
								li = j; found = true;
								for (k in i...len)
								{
									if (s.toLowerCase() == path[k].toLowerCase())
									{
										i = k;
										break;
									} else if (nodot && path[k].charCodeAt(0) == '.'.code) {
										return GlobMatch.NoMatch;
									}
								}
								break;
							case PExact(s,false):
								li = j; found = true;
								for (k in i...len)
								{
									if (s == path[k])
									{
										i = k;
										break;
									} else if (nodot && path[k].charCodeAt(0) == '.'.code) {
										return GlobMatch.NoMatch;
									}
								}
								break;
							case _:
						}
					}
					lastAnyRec = true;

					if (!found)
					{
						if (nodot)
						{
							for (k in i...len)
								if (path[k].charCodeAt(0) == '.'.code)
									return GlobMatch.NoMatch;
						}

						return GlobMatch.Exact;
					}
				case PRegex(r, true,_):
					var acc = cur;
					while(i < len && !r.match(acc))
					{
						acc += "/" + path[i++];
					}

					if (i == len) //last one;
					{
						//we cannot dismiss this, as it may become a valid regex in the future
						//TODO: optimize this so we can filter cases like someName**; they should be pretty rare though
						if (r.match(acc) && li == ll)
							return GlobMatch.Exact;
						else
							return GlobMatch.Partial;
					}
			}
		}

		if (li == ll)
			return GlobMatch.Exact;
		else
			return GlobMatch.Partial;
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

		var pat = new StringBuf(), noEscapePat = new StringBuf();
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
					var s = pat.toString(), ses = noEscapePat.toString();
					pat = new StringBuf();
					noEscapePat = new StringBuf();
					var part = switch [hasConcrete, hasPattern, isWildcard]
					{
					case [true,false,false]:
						s += pathSep;
						PExact(ses, flags.has(NoCase));
					case [false,false,true]:
						if (partials.length != 0 || !isRecursive)
							s += pathSep;
						PAny(isRecursive);
					default:
						var ret = PRegex(new EReg("^" + s + "$", flags.has(NoCase) ? "i" : ""), isRecursive, s);
						s += pathSep;
						ret;
					};
					rawPartials.push(s);
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
				pat.add("(?:[");
				pat.add(notPathSep);
				pat.add("]*)");
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
					throw GError(pattern, i, 'Unmatched ]');
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
					throw GInvalidExclamationPat(pattern, i);
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
					throw GError(pattern, i, "Unexpected |");
				pat.addChar(chr);
				beginPath = beginPathStack[beginPathStack.length-1];

			case ')'.code if(ext):
				if (curLiteral != '('.code)
					throw GError(pattern, i, "Unmatched )");
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
						throw GError(pattern,i, "Invalid escape char");
					hasConcrete = true;
					//edit: it seems that glob considers this acceptable
					if (chr == '\\'.code)
						pat.addChar(chr);
					pat.addChar(chr);
					noEscapePat.addChar(chr);
					break;
				}
				i++;
				hasConcrete = true;
				//escape all possible regex special chars
				switch(chr = StringTools.fastCodeAt(pattern, i))
				{
					case '+'.code, '*'.code, '-'.code, '\\'.code, '/'.code, '['.code, ']'.code, '('.code, ')'.code, '?'.code, '^'.code, '.'.code, '$'.code, '|'.code, '{'.code, '}'.code:
						pat.addChar('\\'.code);
					case _:
				}
				noEscapePat.addChar(chr);
				pat.addChar(chr);
			case '('.code if(ext):
				throw GError(pattern,i, "Invalid '(' without !,+,@,?,*");
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
				noEscapePat.addChar(chr);
			}
		}

		if (inNegate)
		{
			pat.add(").*"); //match anything but this
		}

		if (openLiterals.length != 0)
		{
			throw GError(pattern, pattern.length, 'Unterminated literals: ${openLiterals.map(String.fromCharCode).join(",")}');
		}
		// pat.add("$"); //only exact match

		var s = pat.toString();
		rawPartials.push(s);
		var part = switch [hasConcrete, hasPattern, isWildcard]
		{
		case [true,false,false]:
			PExact(noEscapePat.toString(), flags.has(NoCase));
		case [false,false,true]:
			PAny(isRecursive);
		default:
			PRegex(new EReg("^" + s + "$", flags.has(NoCase) ? "i" : ""), isRecursive,s);
		};
		partials.push(part);

		var pat = "^" + rawPartials.join("") + "$";

		// trace(pat);

		return { exact : new EReg(pat, flags.has(NoCase) ? "i" : ""), partials: partials };
	}

}

/**
	Glob options. Note that some of them may change how the pattern is parsed.
**/
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

/**
	In order to avoid matching a string two times - one for partial and one for exact,
	GlobMatch can be used to return more than one enum flag
 */
abstract GlobMatch(Int)
{
	public static var NoMatch = new GlobMatch(0);
	public static var Partial = new GlobMatch(1);
	public static var Exact = new GlobMatch(2);

	/**
		Is true if a match is exact
	 */
	public var exact(get, never):Bool;
	/**
		Is true if a match is either partial or exact
	 */
	public var matches(get, never):Bool;

	private inline function get_exact():Bool
	{
		return this == 2;
	}

	private inline function get_matches():Bool
	{
		return this != 0;
	}

	private inline function new(v:Int)
	{
		this = v;
	}
}

enum GlobError
{
	/**
		General glob error. A message is included to better describe the issue
	**/
	GError(pattern:String, charPos:Int, msg:String);
	/**
		General parsing error
	**/
	GInvalidPat(pattern:String, charPos:Int);
	/**
		Thrown when the NoExt flag is not set, and an invalid `!` is encountered during parsing
	**/
	GInvalidExclamationPat(pattern:String, charPos:Int);
}

enum GlobPart
{
	PExact(s:String, caseSensitive:Bool); //matches exactly
	PAny(recursive:Bool); //* and **
	PRegex(r:EReg, recursive:Bool,s:String); //is recursive if has globstar (**)
}

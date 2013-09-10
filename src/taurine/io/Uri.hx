package taurine.io;

import haxe.ds.StringMap;

using Lambda;
using StringTools;
using taurine.io.QueryString;

/**
 * ...
 * @author Skial Bainn
 */
class Uri {
	
	private static var _scheme:EReg = ~/^([a-z0-9.+-]+:)/i;
	private static var _port:EReg = ~/:[0-9]*$/;
	private static var _auth:EReg = ~/^\/\/[^@\/]+@[^@\/]+/;
	
	private var uri:String;
	@:isVar public var scheme(default, set):String;
	public var username:String;
	public var password:String;
	public var hostname:String;
	public var port:String;
	public var path:String;
	public var query:StringMap<Array<String>>;
	public var fragment:String;

	public function new(p:String) {
		scheme = username = password = hostname = port = path = fragment = '';
		query = new StringMap<Array<String>>();
		var u = uri = p.trim();
		
		if (_scheme.match( u )) {
			scheme = _scheme.matched(0).replace(':', '');
			u = _scheme.matchedRight();
		}
		
		if (_auth.match( u )) {
			var parts = _auth.matched(0).split( '@' );
			var auth = parts[0].split( ':' );
			
			username = auth[0] == null ? '' : auth[0].replace('/', '');
			password = auth[1] == null ? '' : auth[1];
			
			hostname = parts[1] == null ? '' : parts[1];
			
			u = _auth.matchedRight();
		} else {
			if (u.startsWith( '//' )) u = u.substr( 2 );
			var index = u.length;
			for (char in ['/', '#', '?']) {
				if (u.indexOf( char ) > -1 && u.indexOf( char ) < index) {
					index = u.indexOf( char );
				}
			}
			if (index > -1) {
				hostname = u.substr( 0, index );
				u = u.substr( hostname.length );
			} else {
				hostname = u;
				u = '';
			}
		}
		
		if (_port.match( hostname )) {
			port = _port.matched(0).replace(':', '');
			hostname = _port.matchedLeft();
		}
		
		var fragmentPos = u.lastIndexOf('#');
		if (fragmentPos > -1) {
			fragment = u.substr( fragmentPos + 1 );
			u = u.substr( 0, fragmentPos );
		}
		
		var queryPos = u.lastIndexOf('?');
		if (queryPos > -1) {
			query = u.substr( queryPos + 1 ).parse();
			u = u.substr( 0 , queryPos );
		}
		
		path = u;
	}
	
	public function toString():String {
		var result = '';
		
		if (scheme != '') {
			result += '$scheme://';
		}
		
		if (username != '' && password != '') {
			result += '$username:$password@';
		}
		
		if (hostname != '') {
			if (result == '' && ( uri.startsWith('//') || uri.startsWith('http') )) {
				result += '//';
			}
			
			result += hostname;
			
			if (port != '') {
				result += ':$port';
			}
		}
		
		if (path != '') {
			result += path;
		}
		
		if (query.count() != 0) {
			
			var dot = result.lastIndexOf('.');
			var slash = result.lastIndexOf('/');
			
			if (result != '' && !result.endsWith('/') && (slash == -1)) {
				result += '/';
			}
			
			var queries = query.stringify();
			if (queries != '') {
				result += '?$queries';
			}
			
		}
		
		if (fragment != '') {
			
			var dot = result.lastIndexOf('.');
			var slash = result.lastIndexOf('/');
			
			if (result != '' && !result.endsWith('/') && (dot < slash || slash == -1)) {
				result += '/';
			}
			
			if (!fragment.startsWith('#')) {
				result += '#';
			}
			
			result += fragment;
		}
		
		return result;
	}
	
	private function set_scheme(v:String):String {
		scheme = v.replace(':', '').replace('/', '');
		return scheme;
	}
	
}
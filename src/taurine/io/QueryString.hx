package taurine.io;

import haxe.ds.StringMap;

/**
 * ...
 * @author Skial Bainn
 */
class QueryString {
	
	public static function parse(query:String, ?sep:String = '&', ?eq:String = '='):StringMap<Array<String>> {
		var result = new StringMap<Array<String>>();
		var parts = query.split( sep );
		
		for (part in parts) {
			
			var kv = part.split( eq );
			var k = kv[0];
			var v = kv[1];
			
			if (v == null) v = '';
			
			if (!result.exists( k )) {
				result.set( k, [ v ] );
			} else {
				result.get( k ).push( v );
			}
			
		}
		
		return result;
	}
	
}
package org.tinytlf.css
{
	import asx.array.every;
	import asx.array.filter;
	import asx.array.flatten;
	import asx.array.forEach;
	import asx.array.map;
	import asx.array.reduce;
	import asx.array.some;
	import asx.fn.I;
	import asx.fn.K;
	import asx.fn.apply;
	import asx.fn.callProperty;
	import asx.fn.not;
	import asx.object.merge;
	import asx.string.empty;
	
	import org.tinytlf.Element;
	import org.tinytlf.css.matchers.getMatcher;

	/**
	 * @author ptaylor
	 */
	public function injectCSSPredicates(document:Element, css:String):void {
		
		const predicates:Array = documentPredicates(document);
		
		const blocks:Array = css.
			// Strip white space between blocks
			replace(/\s*([@{}:;,]|\)\s|\s\()\s*|\/\*([^*\\\\]|\*(?!\/))+\*\/|[\n\r\t]/g, '$1').
			// Match blocks
			match(/[^{]*\{([^}]*)*}/g);
		
		const prefixesWithValues:Array = map(filter(blocks, not(empty)), function(block:String):Array {
			// Split the block into two parts: prefix and suffix.
			// prefix is the block's style predicates, suffix is the values.
			const parts:Array = block.split('{');
			const suffix:String = parts.pop().split('}')[0];
			const prefix:String = parts.pop();
			
			// The suffix is easy, build a hashmap of key/value pairs.
			const values:StyleStore = new StyleStore();
			
			forEach(map(filter(suffix.split(';'), not(empty)), callProperty('split', ':')),
				apply(function(name:String, value:String):void {
					values[name] = value;
				}));
			
			// Split on commas, comma is the style aggregation token.
			return [prefix.split(','), values];
		});
		
		const paths:Array = flatten(map(prefixesWithValues, apply(function(prefixes:Array, values:StyleStore):Array {
			return map(prefixes, function(prefix:String):Function {
				
				const tokens:Array = prefix.split(' ');
				var matchedPredicates:Array = predicates.concat();
				
				const mergedWithExistingPredicate:Boolean = some(tokens, function(token:String):Boolean {
					
					const merged:Boolean = some(matchedPredicates, function(predicate:Function):Boolean {
						const val:Function = predicate(token);
						
						if(val == null) return false;
						
						if(val.length == 0) {
							merge(val(), values);
							return true;
						}
						
						return false;
					});
					
					// Early return if we found a matching predicate.
					if(merged) return true;
					
					matchedPredicates = filter(matchedPredicates, function(predicate:Function):Boolean {
						return predicate(token) != null;
					});
					
					return false;
				});
				
				if(mergedWithExistingPredicate) return null;
				
				// build the list of predicate matchers from back-to-front.
				// reduce the list of tokens to a linked-list of predicate-guarded function pointers.
				return reduce(K(values.clone()), tokens.reverse(), getMatcher) as Function;
			});
		})));
		
		// Put the linked path predicates in the top-level predicates list.
		forEach(filter(paths, I), predicates.push);
	}
}

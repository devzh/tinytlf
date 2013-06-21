package org.tinytlf.css
{
	import asx.array.filter;
	import asx.array.forEach;
	import asx.array.reduce;
	import asx.object.keys;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function applyCSSPredicates(document:Element, container:Element, element:Element):Element {
		
		const inheritedPredicates:Array = element == document ?
			documentPredicates(document) :
			container.cssPredicates;
		
		const values:Array = [];
		const predicates:Array = [];
		
		// Match document and inherited css predicates.
		forEach(inheritedPredicates, function(pred:Function):int {
			
			// If the predicate doesn't accept arguments, it's an identity of
			// values inherited from our parents. Add a value function that
			// restricts the values to only inheriting properties.
			if(pred.length == 0) {
				return values.push(function():Object {
					const store:Object = pred();
					const inheritedKeys:Array = filter(keys(store), inheritingProperties.hasOwnProperty);
					return reduce({}, inheritedKeys, function(obj:Object, key:String):Object {
						obj[key] = store[key];
						return obj;
					});
				});
			}
			
			const next:Function = pred(element);
			
			if(next == null) return predicates.push(pred);
			
			if(next.length > 0) return predicates.push(next);
			
			return values.push(next);
		});
		
		// Set the matched style values into the element.
		forEach(values, function(identity:Function):void {
			const store:Object = identity();
			forEach(keys(store), function(style:String):void {
				element.setStyle(style, store[style]);
			});
		});
		
		// Assign the element's CSS predicates so we can keep matching CSS
		// predicates down the element tree.
		element.cssPredicates = values.concat(predicates);
		
		return element;
	}
}
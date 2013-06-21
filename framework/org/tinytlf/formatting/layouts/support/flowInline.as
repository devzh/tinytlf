package org.tinytlf.formatting.layouts.support
{
	import asx.array.filter;
	import asx.array.last;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	import org.tinytlf.enum.TextAlign;
	
	/**
	 * @author ptaylor
	 */
	public function flowInline(floats:Array,
							   flowed:Array,
							   container:Element,
							   element:Element):Element {
		
		const collaborator:Element = last(flowed) as Element;
		
		const float:Function = element.textAlign == TextAlign.RIGHT ? floatRight : floatLeft;
		
		const relevantFloats:Array = getRelevantFloats(floats, collaborator || container);
		
		if(collaborator == null || collaborator == container) {
			return float(
				container, 
				firstFloat(relevantFloats, 'left'), 
				firstFloat(relevantFloats, 'right'), 
				element
			);
		}
		
		return float(
			container,
			collaborator,
			firstFloat(relevantFloats, element.textAlign == TextAlign.LEFT ? 'right' : 'left'),
			element,
			true
		);
	}
}

import asx.array.detect;
import asx.array.filter;
import asx.fn.callProperty;

import org.tinytlf.Edge;
import org.tinytlf.Element;

internal function getRelevantFloats(floats:Array, relativeTo:Element):Array {
	const top:Number = relativeTo.bounds(Element.GLOBAL).top;
	const bottom:Number = relativeTo.bounds(Element.GLOBAL).bottom;
	
	return filter(floats, function(float:Element):Boolean {
		const bounds:Edge = float.bounds(Element.GLOBAL);
		
		// A float is relevent if it vertically intersects with the relativeTo element.
		return bounds.top < bottom &&
			(bounds.bottom + float.marginBottom) > top;
	});
}

internal function firstFloat(floats:Array, type:String):Element {
	return detect(floats, callProperty('floated', type)) as Element;
}

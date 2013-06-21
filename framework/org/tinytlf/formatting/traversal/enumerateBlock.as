package org.tinytlf.formatting.traversal
{
	import asx.fn.I;
	import asx.fn.memoize;

	/**
	 * @author ptaylor
	 */
	public const enumerateBlock:Function = memoize(enumerate, I);
}

import asx.fn.setProperty;

import org.tinytlf.Edge;
import org.tinytlf.Element;
import org.tinytlf.formatting.traversal.support.getFirstStartIndex;
import org.tinytlf.xml.xmlToElement;

import raix.interactive.IEnumerable;
import raix.interactive.toEnumerable;

import trxcllnt.ds.HRTree;

internal function enumerate(element:Element):Function {
	
	var lastBounds:Edge = Edge.empty;
	
	return function(element:Element, cache:HRTree, predicate:Function, index:int):IEnumerable {
		
		const bounds:Edge = element.bounds();
		
		if(bounds.width != lastBounds.width) index = getFirstStartIndex(bounds, cache);
		
		lastBounds = bounds.clone();
		
		return toEnumerable(element.children, index).
			map(xmlToElement).
			map(setProperty('depth', element.depth + 1)).
			takeWhile(predicate);
	}
}

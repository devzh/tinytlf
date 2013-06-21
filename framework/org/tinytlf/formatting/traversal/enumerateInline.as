package org.tinytlf.formatting.traversal
{
	import asx.fn.I;
	import asx.fn.memoize;

	/**
	 * @author ptaylor
	 */
	public const enumerateInline:Function = memoize(enumerate, I);
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
		
		return inlineChildren(element, index).
			map(setProperty('depth', element.depth + 1)).
			takeWhile(predicate);
	}
}

internal function inlineChildren(element:Element, start:int):IEnumerable {
	
	// Enumerates children that render in an inline layout context, like
	// paragraphs. In order to flow inline content around floats, we have to
	// render the floated children first.
	const children:XMLList = element.children;
	const numChildren:int = children.length();
	
	// TODO: This visits all the children of an element, a theoretically
	// expensive operation. The benefit of using Enumerables is that I
	// can start from an index and pull children until we've rendered to
	// the end of the screen, skipping this iteration step. Is there
	// a way to pluck out the floats without visiting every child?
	
	const floats:Array = [];
	const blocks:Array = [];
	
	for(var i:int = start; i < numChildren; ++i) {
		const element:Element = Element.fromXML(children[i]);
		element.floated('left', 'right') ?
			floats.push(element) :
			blocks.push(element);
	}
	
	return toEnumerable(floats).concat(toEnumerable(blocks));
}


package org.tinytlf.formatting.formatters
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function block(document:Element):Function {
		return box(formatter, document);
	}
}

import asx.fn.callProperty;

import org.tinytlf.Element;
import org.tinytlf.formatting.configuration.block.getBlockFormatter;
import org.tinytlf.formatting.traversal.enumerateBlock;

import raix.reactive.IObservable;
import raix.reactive.Observable;

internal function formatter(document:Element, container:Element, predicateFactory:Function, getLayout:Function, layout:Function):Function {
	return function(element:Element):IObservable/*<Element, Boolean>*/ {
		
		if(element.displayed('none')) return Observable.value([element, true]);
		
		return getBlockFormatter(document, element)(
			element,
			predicateFactory,
			enumerateBlock(element),
			getLayout,
			layout,
			callProperty('addTo', container)
		);
	}
}

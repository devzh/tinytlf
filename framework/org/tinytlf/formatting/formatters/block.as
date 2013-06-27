package org.tinytlf.formatting.formatters
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function block(document:Element, asynchronous:Boolean):Function {
		return box(formatter, document, asynchronous);
	}
}

import asx.fn.callProperty;

import org.tinytlf.Element;
import org.tinytlf.formatting.configuration.block.getBlockFormatter;
import org.tinytlf.formatting.traversal.enumerateBlock;

import raix.reactive.IObservable;
import raix.reactive.Observable;

internal function formatter(document:Element,
							container:Element,
							predicateFactory:Function,
							getLayout:Function,
							layout:Function,
							render:Function):Function {
	return function(element:Element):IObservable/*<Element, Boolean>*/ {
		
		if(element.displayed('none')) return Observable.value([element, true]);
		
		const format:Function = getBlockFormatter(document, element);
		const enumerator:Function = enumerateBlock(element);
		
		return format(element, predicateFactory, enumerator, getLayout, layout, render);
	}
}

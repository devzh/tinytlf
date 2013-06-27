package org.tinytlf.display
{
	import org.tinytlf.Element;
	
	import raix.reactive.IObservable;

	/**
	 * @author ptaylor
	 */
	public function renderDocument(document:Element,
								   createUI:Function):Function {
		return expand(document.x, document.y, createUI);
	}
}

import org.tinytlf.Edge;
import org.tinytlf.Element;

import raix.reactive.IObservable;
import raix.reactive.Observable;

import starling.display.DisplayObject;
import starling.display.Quad;

internal function expand(px:Number, py:Number, createUI:Function):Function {
	return function(element:Element):IObservable /*<DisplayObject>*/ {
		
		const bounds:Edge = element.bounds(element.displayed('inline') ? Element.INLINE : Element.LOCAL);
		const x:Number = bounds.left;
		const y:Number = bounds.top;
		var rx:Number = 0;
		var ry:Number = 0;
		
		element.move(px + x, py + y, Element.GLOBAL);
		
		// If the element is relatively positioned, set the position from normal
		// flow, but visually offset it (and all children) by the top and left
		// properties from CSS.
		if(element.positioned('relative')) {
			const constraints:Edge = element.constraints;
			rx = constraints.left;
			ry = constraints.top;
		}
		
		const rendered:IObservable = element.rendered;
		const elements:IObservable = element.elements;
		
		const render:IObservable = rendered.mapMany(createUI);
		const descendents:IObservable = element.numChildren == 0 ?
			Observable.empty() :
			elements.
				/*distinct(getProperty('key')).*/
				mapMany(expand(px + x + rx, py + y + ry, createUI));
		
		return Observable.merge([render, descendents]);
	}
}

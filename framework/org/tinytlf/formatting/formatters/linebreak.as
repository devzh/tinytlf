package org.tinytlf.formatting.formatters
{
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.Element;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;

	/**
	 * @author ptaylor
	 */
	public function linebreak(document:Element, inline:Boolean):Function {
		return function(element:Element,
						getPredicate:Function, /*(element, cache, layout):Function*/
						getEnumerable:Function, /*(startFactory, index):Function*/
						getLayout:Function,
						layout:Function,
						create:Function):IObservable {
			
			element.setStyle('display', inline ? 'inline' : 'block');
			
			if(layout != null) layout(element);
			
			// Set the break's inline bounds too.
			element.size(
				0,
				inline ? element.lineHeight + element.leading : 0,
				Element.LOCAL, Element.INLINE
			);
			
			// Set the height as a style so it takes
			// precedence over other calculated heights.
			element.setStyle('height', element.height);
			
			if(layout != null) layout(element, true);
			
			return Observable.value([element, true]);
		}
	}
}
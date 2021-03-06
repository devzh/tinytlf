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
			
			element.
				setStyle('display', inline ? 'inline' : 'block').
				size(int.MIN_VALUE, 0);
			
			layout(element, false);
			
			// Set the break's inline bounds too.
			element.size(
				int.MIN_VALUE,
				inline ? element.lineHeight + element.leading : 0,
				Element.LOCAL, Element.INLINE
			);
			
			// Set the height as a style so it takes
			// precedence over other calculated heights.
			element.setStyle('height', element.height);
			
			layout(element, true);
			
			return Observable.value([element, true]);
		}
	}
}
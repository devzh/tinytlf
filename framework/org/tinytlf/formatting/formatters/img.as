package org.tinytlf.formatting.formatters
{
	import flash.display.BitmapData;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	import org.tinytlf.net.loadImage;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;

	/**
	 * @author ptaylor
	 */
	public function img(document:Element):Function {
		
		return function(element:Element,
						getPredicate:Function,
						getEnumerable:Function,
						getLayout:Function,
						layout:Function,
						create:Function):IObservable /*<Element, Boolean>*/ {
			
			if(layout != null) layout(element);
			if(create != null) create(element);
			
			// Do the load here so we can report the image's rendered size.
			return loadImage(element.getStyle('url')).
				map(function(data:BitmapData):Array {
					
					const constraints:Edge = element.constrain(data.width, data.height);
					element.size(constraints.width, constraints.height);
					element.setStyle('image', data);
					
					layout(element, true);
					
					return [element, true];
				});
		}
	}
}
package org.tinytlf.formatting.layouts
{
	import org.tinytlf.Element;
	import org.tinytlf.formatting.layouts.support.layout1;
	import org.tinytlf.formatting.layouts.support.layout2;

	/**
	 * @author ptaylor
	 */
	internal function layout(document:Element, flowRoot:Element, floats:Array, flowed:Array):Function {
		
		return function(container:Element):Function {
			
			const l1:Function = layout1(floats, flowed, document, flowRoot, container);
			const l2:Function = layout2(floats, flowed, document, flowRoot, container);
			
			return function(element:Element, rendered:Boolean = false, addToFlowCache:Boolean = true):Element {
				
				// Don't layout elements if their display property indicates
				// they're not a visual element.
				if(element.displayed.apply(element, nonVisualElements)) return element;
				
				return rendered ? l2(element, addToFlowCache) : l1(element, addToFlowCache);
			}
		}
	}
}

internal const nonVisualElements:Array = ['none', 'table-column', 'table-column-group'];

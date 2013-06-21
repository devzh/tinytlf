package org.tinytlf.formatting.layouts.support
{
	import org.tinytlf.Element;
	
	import raix.reactive.scheduling.Scheduler;

	/**
	 * @author ptaylor
	 */
	public function layout1(floats:Array,
							flowed:Array,
							document:Element,
							flowRoot:Element,
							container:Element):Function {
		
		const anti:Function = antiFlow(document, flowRoot);
		
		return function(element:Element, addToFlowCache:Boolean = true):Element {
			
			if(element.positioned('fixed', 'absolute')) return anti(element);
			if(element.floated('left', 'right')) return anti(element);
			
			if(element.displayed('table-cell')) flowTableCell(flowed, container, element);
			else if(element.displayed('inline', 'inline-block')) flowInline(floats, flowed, container, element);
			else flowBlock(flowed, container, element);
			
			// Flowed elements have to be added to the flowed elements cache
			// as soon as they're visited.
			if(addToFlowCache) flowed.push(element);
			
			return element;
		}
	}
}

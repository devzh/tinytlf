package org.tinytlf.formatting.layouts.support
{
	import org.tinytlf.Element;
	
	import raix.reactive.ISubject;
	import raix.reactive.scheduling.Scheduler;
	
	/**
	 * @author ptaylor
	 */
	public function antiFlow(document:Element, flowRoot:Element):Function {
		
		var leftFloat:Element;
		var rightFloat:Element;
		
		return function(element:Element):Element {
			
			if(element.positioned('fixed', 'absolute')) absolute(element);
			else if(element.floated('left')) leftFloat = floatLeft(flowRoot, leftFloat, rightFloat, element);
			else if(element.floated('right')) rightFloat = floatRight(flowRoot, rightFloat, leftFloat, element);
			
			return element;
		}
	}

}
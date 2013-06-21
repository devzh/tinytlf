package org.tinytlf.css
{
	import asx.array.forEach;
	import asx.fn.partial;
	import asx.object.mergeSealed;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function inheritCSSPredicates(document:Element, container:Element):Function{
		return function(element:Element):Element {
			return applyCSSPredicates(document, container, element);
		}
	}
}
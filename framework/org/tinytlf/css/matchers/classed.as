package org.tinytlf.css.matchers
{
	import org.tinytlf.Element;
	
	/**
	 * @author ptaylor
	 */
	internal function classed(className:String, next:Function):Function {
		return function(element:Object):Function {
			return element is Element ?
				Element(element).classed(className) ?
					next : null :
				element == className ?
					next : null;
		}
	}
}
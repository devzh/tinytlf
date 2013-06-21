package org.tinytlf.css.matchers
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	internal function namedWithClass(name:String, className:String, next:Function):Function {
		return function(element:Object):Function {
			return named(name, next)(element) && classed(className, next)(element);
		}
	}
}
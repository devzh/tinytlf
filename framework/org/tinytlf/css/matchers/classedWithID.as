package org.tinytlf.css.matchers
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	internal function classedWithID(id:String, className:String, next:Function):Function {
		return function(element:Object):Function {
			return withID(id, next)(element) && classed(className, next)(element);
		}
	}
}
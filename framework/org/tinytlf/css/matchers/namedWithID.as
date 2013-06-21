package org.tinytlf.css.matchers
{
	import org.tinytlf.Element;
	
	/**
	 * @author ptaylor
	 */
	internal function namedWithID(name:String, id:String, next:Function):Function {
		return function(element:Object):Function {
			return named(name, next)(element) && withID(id, next)(element);
		}
	}
}
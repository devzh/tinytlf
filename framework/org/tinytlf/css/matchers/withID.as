package org.tinytlf.css.matchers
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	internal function withID(id:String, next:Function):Function {
		return function(element:Object):Function {
			return element is Element ?
				Element(element).id == id ?
					next : null :
				element == id ?
					next : null;
		}
	}
}
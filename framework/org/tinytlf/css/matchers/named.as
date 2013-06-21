package org.tinytlf.css.matchers
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	internal function named(name:String, next:Function):Function {
		return function(element:Object):Function {
			return element is Element ?
				Element(element).name == name ?
					next : null :
				element == name ?
					next : null;
		}
	}
}
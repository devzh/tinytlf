package org.tinytlf.xml
{
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function keyToElement(key:String, element:Element = null):Element {
		return elementCache[key] = element || elementCache[key] || new Element();
	}
}

internal const elementCache:Object = {};
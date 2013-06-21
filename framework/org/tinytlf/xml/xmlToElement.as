package org.tinytlf.xml
{
	import asx.fn.memoize;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function xmlToElement(node:XML):Element {
		const key:String = readKey(node);
		const element:Element = keyToElement(key);
		
		element.node = node;
		mergeAttributes(element, node);
		
		return element;
	}
}
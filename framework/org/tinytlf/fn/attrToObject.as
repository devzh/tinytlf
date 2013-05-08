package org.tinytlf.fn
{
	import asx.array.toDictionary;
	import asx.fn.callXMLProperty;

	/**
	 * @author ptaylor
	 */
	public function attrToObject(attributes:XMLList):Object {
		return toDictionary(
			attributes,
			callXMLProperty('localName'),
			callXMLProperty('toString')
		)
	}
}
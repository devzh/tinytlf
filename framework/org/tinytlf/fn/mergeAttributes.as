package org.tinytlf.fn
{
	import asx.object.merge;

	/**
	 * @author ptaylor
	 */
	public function mergeAttributes(target:Object, value:XML):Object {
		return merge(target, attrToObject(value.attributes()))
	}
}
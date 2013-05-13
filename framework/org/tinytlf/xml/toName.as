package org.tinytlf.xml
{
	import asx.array.filter;

	/**
	 * @author ptaylor
	 */
	// parent#parentId .one .two child#id:0 .one .two
	public function toName(key:String):String {
		return key.split(' ').
			pop().
			split(':').shift().
			split('#').shift();
	}
}
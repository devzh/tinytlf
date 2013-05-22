package org.tinytlf.xml
{

	/**
	 * @author ptaylor
	 */
	public function readKey(node:XML):String {
		return keys[node] ||= toKey(node);
	}
}

import flash.utils.Dictionary;

internal const keys:Dictionary = new Dictionary(true);
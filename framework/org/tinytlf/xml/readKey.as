package org.tinytlf.xml
{

	/**
	 * @author ptaylor
	 */
	public function readKey(node:XML):String {
		return node.@cssInheritanceChain || addKey(node).@cssInheritanceChain;
	}
}
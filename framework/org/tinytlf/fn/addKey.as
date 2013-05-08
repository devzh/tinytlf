package org.tinytlf.fn
{
	/**
	 * @author ptaylor
	 */
	public function addKey(node:XML):XML {
		node.@cssInheritanceChain = toKey(node);
		return node;
	}	
}
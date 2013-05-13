package org.tinytlf.xml
{
	/**
	 * Get the fully traversed inheritance chain of an XML node,
	 * including parent nodes, class list, and IDs.
	 */
	public function toKey(node:XML):String
	{
		const index:int = node.childIndex();
		const name:String = node.localName() || 'text';
		const parent:XML = node.parent();
		
		const classes:String = String(node.@['class'] || '').split(' ').join('.');
		const id:String = node.@id.length > 0 ? '#' + node.@id : '';
		const existingChain:String = parent ? parent.@cssInheritanceChain : '';
		
		return existingChain + (existingChain ? ' ' : '') + name + (index == -1 ? '' : ':' + index) + id + (classes ? '.' : '') + classes;
	}
}
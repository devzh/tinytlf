package org.tinytlf.model
{
	public interface ITLFNodeParent extends ITLFNode
	{
		/**
		 * The number of children this ITextNode has.
		 */
		function get numChildren():int;
		
		/**
		 * Adds the specified node to the end of the child list.
		 * 
		 * @return The added node.
		 */
		function addChild(node:ITLFNode):ITLFNode;
		
		/**
		 * Inserts the specified node at the specified index. If the node is
		 * already a child, this adjusts the child position in the child list.
		 * 
		 * @return The inserted node.
		 */
		function addChildAt(node:ITLFNode, index:int):ITLFNode;
		
		/**
		 * Adds the specified nodes to the end of the child list.
		 * 
		 * @return Returns a Vector populated with the added nodes.
		 */
		function addChildren(kids:Vector.<ITLFNode>):Vector.<ITLFNode>;
		
		/**
		 * Removes the specified child from the list.
		 * 
		 * @return The node removed.
		 */
		function removeChild(node:ITLFNode):ITLFNode;
		
		/**
		 * Removes the child at the specified index.
		 * 
		 * @return The node removed.
		 */
		function removeChildAt(index:int):ITLFNode;
		
		/**
		 * Removes the specified children.
		 * 
		 * @return Returns a Vector populated with the removed nodes.
		 */
		function removeChildren(kids:Vector.<ITLFNode>):Vector.<ITLFNode>;
		
		/**
		 * Returns the child at the specified index.
		 */
		function getChildAt(index:int):ITLFNode;
		
		/**
		 * Returns the index of the specified child.
		 */
		function getChildIndex(node:ITLFNode):int;
		
		/**
		 * Returns the position of the child in the tree.
		 */
		function getChildPosition(index:int):int;
		
		/**
		 * Returns the index of the child at the given position.
		 */
		function getChildIndexAtPosition(at:int):int;
		
		/**
		 * Swaps the positions of the specified children.
		 */
		function swapChildren(child1:ITLFNode, child2:ITLFNode):void;
	}
}
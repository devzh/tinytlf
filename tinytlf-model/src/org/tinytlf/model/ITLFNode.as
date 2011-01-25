package org.tinytlf.model
{
	import flash.text.engine.ContentElement;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.styles.IStyleAware;

	public interface ITLFNode extends IStyleAware
	{
		function get contentElement():ContentElement;
		function set contentElement(value:ContentElement):void;
		
		function get engine():ITextEngine;
		function set engine(textEngine:ITextEngine):void;
		
		/**
		 * @return The length of this ITextNode
		 */
		function get length():int;
		
		/**
		 * The name of this node.
		 */
		function get name():String;
		function set name(value:String):void;
		
		/**
		 * @return A plain-text representation of the value of this ITextNode.
		 */
		function get text():String;
		
		/**
		 * @return The type of node, container or leaf.
		 * @see ITLFNodeType
		 */
		function get type():String;
		
		/**
		 * Signals to the ITLFNode that its styles are outdated and should
		 * be re-cached. This is called whenever an ITLFNode is added or removed
		 * from an ITLFNodeParent, or whenever external actions cause the styles
		 * cache to become invalid (such as loading another StyleSheet into the
		 * TextStyler class).
		 */
		function regenerateStyles():void;
		
		/**
		 * The immediate parent of this ITextNode.
		 */
		function get parent():ITLFNodeParent;
		
		/**
		 * Inserts the specified value at the specified index. The value can
		 * be either a String or an ITextNode instance.
		 * 
		 * If the value is a String, the String will be inserted into the leaf
		 * at the position, keeping that leaf's formatting properties. If the
		 * value is an ITextNode, the leaf will be split at the index, becoming
		 * a container, and the value will be inserted at the specified index.
		 * 
		 * @return The ITextNode that was modified. Note, this is not
		 * necessarily the ITextNode instance that was called.
		 */
		function insert(value:Object, at:int):ITLFNode;
		
		/**
		 * Removes the range specified by the start and end values.
		 * 
		 * @return The ITextNode that was modified. This is not necessarily
		 * the ITextNode instance that was called, though if the range
		 * specified ITextNode children, then it most likely will be.
		 */
		function remove(start:int, end:int = int.MAX_VALUE):ITLFNode;
		
		/**
		 * Splits the ITextNode at the specified index.
		 * 
		 * @return The ITextNode which is the parent of the new node instances.
		 */
		function split(at:int):ITLFNode;
		
		/**
		 * Merges the nodes from the start position to the end position. This
		 * operation flattens the tree and combines all the text from the
		 * affected nodes into a single Leaf node.
		 * 
		 * @return The parent ITextNode of the affected nodes.
		 */
		function merge(start:int, end:int):ITLFNode;
		
		/**
		 * Creates and returns a copy of this ITextNode.
		 */
		function clone(start:int = 0, end:int = int.MAX_VALUE):ITLFNode;
		
		/**
		 * Returns the lowest level leaf node at the specified position.
		 */
		function getLeaf(at:int):ITLFNode;
	}
}
package org.tinytlf.layout.orientation
{
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.IConstraintTextContainer;

	public interface IFlowOrientation
	{
		/**
		 * Called just before layout begins in the target container.
		 */
		function preLayout():void;
		
		/**
		 * Called by the IFlowLayout just before layout on this TextBlock begins.
		 * Allows the IFlowDirectionDelegate to adjust before rendering the next
		 * paragraph.
		 */
		function prepForTextBlock(block:TextBlock, line:TextLine):void;
		
		/**
		 * Sets the x and y positions of the TextLine.
		 */
		function position(latestLine:TextLine):void;
		
		/**
		 * The IFlowLayout this direction delegate belongs to/acts on.
		 */
		function set target(flowLayout:IConstraintTextContainer):void;
		
		/**
		 * The current layout position for the orientation.
		 */
		function get value():Number;
	}
}
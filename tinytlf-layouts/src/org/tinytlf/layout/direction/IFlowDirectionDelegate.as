package org.tinytlf.layout.direction
{
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.IFlowLayout;

	public interface IFlowDirectionDelegate
	{
		/**
		 * Returns true if layout has moved outside the constraints of the
		 * target container, false if we're still within bounds.
		 */
		function checkTargetConstraints():Boolean;
		
		/**
		 * Calculates the width of the newest TextLine.
		 */
		function getLineSize(block:TextBlock, previousLine:TextLine):Number;
		
		/**
		 * Sets the x and y positions of the TextLine.
		 */
		function layoutLine(latestLine:TextLine):void;
		
		/**
		 * Called by the IFlowLayout just before layout on this TextBlock begins.
		 * Allows the IFlowDirectionDelegate to adjust before rendering the next
		 * paragraph.
		 */
		function prepForTextBlock(block:TextBlock):void;
		
		/**
		 * The IFlowLayout this direction delegate belongs to/acts on.
		 */
		function set target(flowLayout:IFlowLayout):void;
	}
}
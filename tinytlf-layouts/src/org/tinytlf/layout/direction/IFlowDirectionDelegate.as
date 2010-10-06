package org.tinytlf.layout.direction
{
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.IFlowLayout;

	public interface IFlowDirectionDelegate
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
		 * Calculates the width of the newest TextLine.
		 */
		function getLineSize(block:TextBlock, previousLine:TextLine):Number;
		
		/**
		 * Sets the x and y positions of the TextLine.
		 */
		function layoutLine(latestLine:TextLine):void;
		
		/**
		 * Returns true if layout has moved outside the constraints of the
		 * target container, false if we're still within bounds.
		 */
		function checkTargetConstraints(latestLine:TextLine):Boolean;
		
		/**
		 * Called from the IFlowLayout when an IFlowLayoutElement has been
		 * detected in a TextLine.
		 * 
		 * @returns Boolean true if this IFlowLayoutElement should cause the
		 * IFlowLayout to block processing any more IFlowLayoutElements, false
		 * if it should continue.
		 */
		function registerFlowElement(line:TextLine, atomIndex:int):Boolean;
		
		/**
		 * The IFlowLayout this direction delegate belongs to/acts on.
		 */
		function set target(flowLayout:IFlowLayout):void;
	}
}
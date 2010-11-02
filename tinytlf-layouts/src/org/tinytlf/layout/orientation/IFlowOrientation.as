package org.tinytlf.layout.orientation
{
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.IConstraintTextContainer;

	public interface IFlowOrientation
	{
		/**
		 * Called on every ITextContainer just before layout begins.
		 */
		function preLayout():void;
		
		/**
		 * Called on every ITextContainer after the entire layout pass ends.
		 */
		function postLayout():void;
		
		/**
		 * Called by the IFlowLayout just before layout on this TextBlock begins.
		 * Allows the IFlowDirectionDelegate to adjust before rendering the next
		 * paragraph.
		 */
		function prepForTextBlock(block:TextBlock, line:TextLine):void;
		
		/**
		 * Called by the IFlowLayout just before layout on this TextBlock begins.
		 * Allows the IFlowDirectionDelegate to adjust before rendering the next
		 * paragraph.
		 */
		function postTextBlock(block:TextBlock):void;
		
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
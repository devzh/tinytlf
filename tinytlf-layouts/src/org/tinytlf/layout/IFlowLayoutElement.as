package org.tinytlf.layout
{
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextLine;

	public interface IFlowLayoutElement
	{
		/**
		 * The ContentElement this IFlowElement represents.
		 */
		function get element():ContentElement;
		function set element(value:ContentElement):void;
		
		/**
		 * The TextLine this IFlowElement belongs to.
		 */
		function get textLine():TextLine;
		function set textLine(value:TextLine):void;
		
		/**
		 * The x of this element relative to the rest of the TextLines.
		 */
		function set x(value:Number):void;
		function get x():Number;
		
		/**
		 * The y of this element relative to the rest of the TextLines.
		 */
		function set y(value:Number):void;
		function get y():Number;
		
		function get width():Number;
		function get height():Number;
		
		/**
		 * Calculates whether the given x is within the x bounds of this 
		 * IFlowLayoutElement.
		 */
		function containsX(x:Number):Boolean;
		
		/**
		 * Calculates whether the given y is within the y- bounds of this 
		 * IFlowLayoutElement.
		 */
		function containsY(y:Number):Boolean;
	}
}
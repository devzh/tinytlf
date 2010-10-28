package org.tinytlf.layout.orientation
{
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;

	public interface IMajorOrientation extends IFlowOrientation
	{
		/**
		 * Called from the IFlowLayout when an IFlowLayoutElement has been
		 * detected in a TextLine.
		 * 
		 * @returns Boolean true if this IFlowLayoutElement should cause the
		 * IFlowLayout to block processing any more IFlowLayoutElements, false
		 * if it should continue.
		 */
		function registerConstraint(line:TextLine, atomIndex:int):Boolean;
		
		/**
		 * Calculates the width of the newest TextLine.
		 */
		function getLineSize(block:TextBlock, previousLine:TextLine):Number;
	}
}
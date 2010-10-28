package org.tinytlf.layout.orientation
{
	import flash.text.engine.TextLine;

	public interface IMinorOrientation extends IFlowOrientation
	{
		/**
		 * Returns true if layout has moved outside the constraints of the
		 * target container, false if we're still within bounds.
		 */
		function checkTargetBounds(latestLine:TextLine):Boolean;
	}
}
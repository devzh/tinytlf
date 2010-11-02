package org.tinytlf.layout
{
	import org.tinytlf.layout.constraints.*;
	import org.tinytlf.layout.orientation.*;

	public interface IConstraintTextContainer extends ITextContainer
	{
		/**
		 * The primary direction of the TextLines in a TextField. Determines the
		 * width of each TextLine, and positions the TextLine along the major
		 * axis.
		 * 
		 * For left-to-right and right-to-left, this determines the width of 
		 * each TextLine, as well as the X position, including floating
		 * around inline graphics and list items.
		 * 
		 * For top-to-bottom and bottom-to-top, this determines the height of
		 * each TextLine, as well as the Y position.
		 */
		function get majorDirection():IMajorOrientation;
		function set majorDirection(delegate:IMajorOrientation):void;
		
		/**
		 * The secondary direction in text layout. For left-to-right or 
		 * right-to-left text, this determines the Y position of each TextLine.
		 * For top-to-bottom or bottom-to-top, this determines the X position
		 * of each TextLine.
		 */
		function get minorDirection():IMinorOrientation;
		function set minorDirection(delegate:IMinorOrientation):void;
		
		/**
		 * The factory which generates custom constraint types from the rendered
		 * Text Lines.
		 */
		function get constraintFactory():IConstraintFactory;
		function set constraintFactory(factory:IConstraintFactory):void;
		
		/**
		 * A read-only list of active constraints.
		 */
		function get constraints():Vector.<ITextConstraint>;
		
		function addConstraint(constraint:ITextConstraint):void;
		function getConstraint(element:*):ITextConstraint;
		function removeConstraint(constraint:ITextConstraint):void;
	}
}
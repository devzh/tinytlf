package org.tinytlf.layout.constraints
{
	import flash.text.engine.TextLine;

	/**
	 * A text constraint is an element in a TextField which can't have any 
	 * overlap with other constraints.
	 * 
	 * When an image in a TextLine is detected, a constraint is created for it.
	 */
	public interface ITextConstraint
	{
		/**
		 * Initializes the constraint. The constraintElement argument can be
		 * any object detected within the TextLine, including the TextLine
		 * itself.
		 */
		function initialize(element:*):void;
		
		function get content():*;
		function get constraintMarker():Object;
		function get float():String;
		
		function get majorValue():Number;
		function set majorValue(value:Number):void;
		
		function get majorSize():Number;
		function set majorSize(value:Number):void;
		
		function getMajorValue(atMinor:Number, fromMajor:Number):Number;
	}
}
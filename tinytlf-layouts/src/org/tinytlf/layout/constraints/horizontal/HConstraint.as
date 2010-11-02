package org.tinytlf.layout.constraints.horizontal
{
	import flash.text.engine.ContentElement;
	
	import org.tinytlf.layout.constraints.TextConstraintBase;
	import org.tinytlf.layout.properties.TextFloat;
	
	/**
	 * The base class for a constraint that exists within a horizontal ltr or
	 * rtl text field.
	 */
	public class HConstraint extends TextConstraintBase
	{
		public function HConstraint(constraintElement:ContentElement = null)
		{
			super(constraintElement);
		}
		
		override public function get majorValue():Number
		{
			return lp.x;
		}
		
		override public function set majorValue(value:Number):void
		{
			lp.x = value;
		}
		
		override public function get majorSize():Number
		{
			return totalWidth;
		}
		
		override public function set majorSize(value:Number):void
		{
			lp.width = value;
		}
		
		override public function getMajorValue(atMinor:Number, fromMajor:Number):Number
		{
			if(atMinor < lp.y)
				return -1;
			
			if(atMinor > (lp.y + totalHeight))
				return -1;
			
			if(fromMajor < lp.x)
				return fromMajor;
			
			if(fromMajor >= lp.x && fromMajor < (lp.x + totalWidth))
				return (lp.x + totalWidth);
			
			return fromMajor;
		}
	}
}
package org.tinytlf.layout.constraints.vertical
{
	import flash.text.engine.ContentElement;
	
	import org.tinytlf.layout.constraints.TextConstraintBase;
	
	/**
	 * The base class for a constraint that exists within a vertical ttb or btt
	 * text field.
	 */
	public class VConstraint extends TextConstraintBase
	{
		public function VConstraint(constraintElement:ContentElement = null)
		{
			super(constraintElement);
		}
		
		override public function get majorValue():Number
		{
			return lp.y;
		}
		
		override public function get majorSize():Number
		{
			return totalHeight;
		}
		
		override public function getMajorValue(atMinor:Number, fromMajor:Number):Number
		{
			if(atMinor < lp.x)
				return -1;
			
			if(atMinor > (lp.x + totalWidth))
				return -1;
			
			if(fromMajor < lp.y)
				return fromMajor;
			
			if(fromMajor >= lp.y && fromMajor < (lp.y + totalHeight))
				return (lp.y + totalHeight);
			
			return fromMajor;
		}
	}
}
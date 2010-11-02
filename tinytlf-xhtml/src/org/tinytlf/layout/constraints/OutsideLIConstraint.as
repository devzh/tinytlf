package org.tinytlf.layout.constraints
{
	import org.tinytlf.layout.constraints.horizontal.HConstraint;
	import org.tinytlf.layout.properties.TextFloat;
	
	public class OutsideLIConstraint extends HConstraint
	{
		public function OutsideLIConstraint(constraintElement:* = null)
		{
			super(constraintElement);
		}
		
		override public function get float():String
		{
			return TextFloat.LEFT;
		}
		
		override public function getMajorValue(atMinor:Number, fromMajor:Number):Number
		{
			return lp.x + totalWidth;
		}
	}
}
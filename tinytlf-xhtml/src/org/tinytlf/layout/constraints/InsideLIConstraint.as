package org.tinytlf.layout.constraints
{
	import flash.text.engine.ContentElement;
	
	import org.tinytlf.layout.constraints.horizontal.HConstraint;
	import org.tinytlf.layout.properties.TextFloat;
	
	public class InsideLIConstraint extends HConstraint
	{
		public function InsideLIConstraint(constraintElement:* = null)
		{
			super(constraintElement);
		}
		
		override public function get float():String
		{
			return TextFloat.LEFT;
		}
		
		override public function initialize(e:*):void
		{
			super.initialize(e);
			
			lp.x = majorSize;
		}
		
		override public function getMajorValue(atMinor:Number, fromMajor:Number):Number
		{
			return lp.x;
		}
	}
}
package org.tinytlf.layout.constraints
{
	import flash.text.engine.ContentElement;
	
	import org.tinytlf.layout.constraints.horizontal.HConstraint;
	
	public class ListItemConstraint extends HConstraint
	{
		public function ListItemConstraint(constraintElement:ContentElement = null)
		{
			super(constraintElement);
		}
		
		override public function getMajorValue(atMinor:Number, fromMajor:Number):Number
		{
			return lp.x + totalWidth;
		}
	}
}
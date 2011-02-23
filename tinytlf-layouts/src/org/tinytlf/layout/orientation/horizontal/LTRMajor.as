package org.tinytlf.layout.orientation.horizontal
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.constraints.*;
	import org.tinytlf.layout.constraints.horizontal.HConstraintFactory;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.TinytlfUtil;
	
	/**
	 * The IMajorOrientation implementation for left-to-right languages.
	 */
	public class LTRMajor extends HOrientationBase
	{
		public function LTRMajor(target:IConstraintTextContainer)
		{
			super(target);
			
			target.constraintFactory = new HConstraintFactory();
		}
		
		private var x:Number = 0;
		private var leftConstraint:Number = 0;
		private var rightConstraint:Number = 0;
		
		override public function get value():Number
		{
			return x;
		}
		
		override public function preLayout():void
		{
			super.preLayout();
			
			x = 0;
			leftConstraint = 0;
			rightConstraint = getTotalSize();
		}
		
		override public function prepForTextBlock(block:TextBlock, line:TextLine):void
		{
			super.prepForTextBlock(block, line);
			
			// Search through the list of constraints, removing any that exist
			// after the line we're starting from. If line is null, we know
			// we're re-rendering starting from the first line, so this will
			// remove all constraints for this textBlock.
			// 
			// We have to do this because we'll recreate the constraint when
			// we re-render the line that the constraint exists in.
			
			var constraints:Vector.<ITextConstraint> = target.constraints;
			var n:int = constraints.length;
			var c:ITextConstraint;
			var elem:ContentElement;
			
			var lineBlockBeginIndex:int = line ? line.textBlockBeginIndex : -1;
			
			for(var i:int = 0; i < n; i += 1)
			{
				c = constraints[i];
				if(c.content is ContentElement)
				{
					elem = ContentElement(c.content);
					if(elem.textBlock == block)
						if(elem.textBlockBeginIndex > lineBlockBeginIndex)
							target.removeConstraint(c);
				}
			}
			
			evaluateConstraints(block);
		}
		
		override public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			evaluateConstraints(block);
			
			return rightConstraint - leftConstraint;
		}
		
		override public function position(line:TextLine):void
		{
			evaluateConstraints(line);
			
			var lp:LayoutProperties = TinytlfUtil.getLP(line);
			
			switch(lp.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					positionLeft(line);
					break;
				case TextAlign.CENTER:
					positionCenter(line);
					break;
				case TextAlign.RIGHT:
					positionRight(line);
					break;
			}
		}
		
		override protected function handleConstraint(line:TextLine, constraint:ITextConstraint):void
		{
			super.handleConstraint(line, constraint);
			
			if(!constraint.constraintMarker)
				return;
			
			if(constraint.float)
			{
				switch(constraint.float)
				{
					case TextFloat.LEFT:
						constraint.majorValue = leftConstraint;
						break;
					case TextFloat.RIGHT:
						constraint.majorValue = rightConstraint - constraint.majorSize;
						break;
				}
				
				line.x = constraint.majorValue;
			}
			
			evaluateConstraints(line);
		}
		
		private function evaluateConstraints(around:Object):void
		{
			var c:ITextConstraint;
			var constraints:Vector.<ITextConstraint> = target.constraints;
			var n:int = constraints.length;
			
			var minorValue:Number = target.minorDirection.value;
			var l:Number = 0;
			var totalWidth:Number = getTotalSize();
			var r:Number = totalWidth;
			var majorValue:Number = -1;
			
			for(var i:int = 0; i < n; i += 1)
			{
				c = constraints[i];
				
				majorValue = c.getMajorValue(minorValue, l);
				
				if(majorValue == -1)
					continue;
				
				if(c.float)
				{
					if(c.float == TextFloat.LEFT)
					{
						if(majorValue >= l){
							l = majorValue;
						}
					}
					else if(c.float == TextFloat.RIGHT)
					{
						if(majorValue < r){
							r = majorValue;
						}
					}
				}
				else
				{
					if(c.majorValue <= l)
						l = majorValue;
					if(c.majorValue >= r)
						r = c.majorValue;
				}
			}
			
			leftConstraint = Math.min(l, totalWidth);
			rightConstraint = Math.max(r, 0);
			
			var lp:LayoutProperties = TinytlfUtil.getLP(around);
			switch(lp.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					x = leftConstraint;
					break;
				case TextAlign.CENTER:
					x = (totalWidth * .5) + (l * .5) - (r * .5);
					break;
				case TextAlign.RIGHT:
					x = rightConstraint;
					break;
			}
		}
		
		private function positionLeft(line:TextLine):void
		{
			line.x = leftConstraint;
			x = leftConstraint + line.specifiedWidth;
			if(x >= rightConstraint)
				x = getTotalSize(line);
		}
		
		private function positionCenter(line:TextLine):void
		{
			line.x = x;
			x += line.specifiedWidth;
			
			if(x > rightConstraint)
				x = getTotalSize(line);
		}
		
		private function positionRight(line:TextLine):void
		{
			line.x = rightConstraint - line.specifiedWidth;
			x = line.x;
			if(x <= leftConstraint)
				x = 0;
		}
	}
}

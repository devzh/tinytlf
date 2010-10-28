package org.tinytlf.layout.orientation.horizontal
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.constraints.*;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.TinytlfUtil;
	
	/**
	 * The IMajorOrientation implementation for right-to-left languages.
	 * 
	 * TODO: implement!
	 */
	public class RTLMajor extends HOrientationBase
	{
		public function RTLMajor(target:IConstraintTextContainer)
		{
			super(target);
		}
		
		override public function preLayout():void
		{
			super.preLayout();
			
			x = 0;
		}
		
		private var x:Number = 0;
		
		override public function prepForTextBlock(block:TextBlock, line:TextLine):void
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			
			if(line)
			{
				if(target.hasLine(line))
				{
					var totalWidth:Number = getTotalSize(block);
					
					switch(lp.textAlign)
					{
						case TextAlign.LEFT:
						case TextAlign.JUSTIFY:
							x = 0;
							break;
						case TextAlign.RIGHT:
							x = totalWidth;
							break;
					}
				}
				
				return;
			}
			
			x = lp.textIndent;
		}
		
		override public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			var totalSize:Number = super.getLineSize(block, previousLine);
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			switch(lp.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					return sizeFromLeft(totalSize, previousLine);
					break;
				case TextAlign.RIGHT:
					return sizeFromRight(totalSize, previousLine);
					break;
			}
			
			return totalSize;
		}
		
		override public function position(line:TextLine):void
		{
			//position here, don't rely on the sizing method to set the position.
			var lp:LayoutProperties = TinytlfUtil.getLP(line);
			switch(lp.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					positionFromLeft(line);
					break;
				case TextAlign.RIGHT:
					break;
			}
		}
		
		override public function get value():Number
		{
			return x;
		}
		
		private function sizeFromLeft(total:Number, previousLine:TextLine):Number
		{
			var elements:Vector.<ITextConstraint> = target.constraints;
			var el:ITextConstraint;
			
			var size:Number = total;
			var xPos:Number = x;
			var n:int = elements.length;
			
			var elX:Number = 0;
			
			for(var i:int = 0; i < n; i += 1)
			{
				el = elements[i];
				
				elX = el.getMajorValue(target.minorDirection.value, xPos);
				
				// If there's no major direction value for this constraint, it
				// musn't exist within this minor direction. Skip it.
				if(elX == -1)
					continue;
				
				// Current xPos doesn't intersect with the constraint.
				// it can be either on the left or right.
				if(elX == xPos)
				{
					// If xPos is to the left of the majorValue, optionally 
					// update the size.
					if(xPos < el.majorValue)
					{
						size = Math.min(size, el.majorValue - xPos);
					}
					
					// if xPos is to the right, we don't care about this constraint,
					// so we don't have anything to update.
				}
				// Otherwise, the xPos intersected with the bounds of the 
				// constraint. update xPos and move on.
				else
				{
					xPos = elX;
				}
			}
			
			return size;
		}
		
		private function positionFromLeft(line:TextLine):void
		{
			line.x = x;
			x += line.specifiedWidth;
			
			var el:ITextConstraint;
			var constraints:Vector.<ITextConstraint> = target.constraints;
			var n:int = constraints.length;
			var elX:Number = 0;
			
			var y:Number = target.minorDirection.value;
			
			for(var i:int = 0; i < n; i += 1)
			{
				el = constraints[i];
				elX = el.getMajorValue(y, x);
				
				if(elX == -1)
					continue;
				
				x = elX;
			}
		}
		
		private function sizeFromRight(total:Number, previousLine:TextLine):Number
		{
			//TODO: implement
			var xPos:Number = total;
			
			return total;
		}
	}
}

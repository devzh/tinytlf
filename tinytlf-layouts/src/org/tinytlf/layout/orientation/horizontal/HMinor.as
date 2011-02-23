package org.tinytlf.layout.orientation.horizontal
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.IConstraintTextContainer;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.*;
	
	/**
	 * The IMinorOrientation implementation for left-to-right and right-to-left
	 * languages.
	 */
	public class HMinor extends HOrientationBase
	{
		public function HMinor(target:IConstraintTextContainer)
		{
			super(target);
		}
		
		private var y:Number = 0;
		
		override public function preLayout():void
		{
			super.preLayout();
			
			y = 0;
		}
		
		override public function prepForTextBlock(block:TextBlock, line:TextLine):void
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			
			if(line)
			{
				if(target.hasLine(line))
				{
					y = line.y + line.descent + lp.leading;
				}
			}
			else
			{
				y += lp.paddingTop;
			}
		}
		
		override public function postTextBlock(block:TextBlock):void
		{
			y += TinytlfUtil.getLP(block).paddingBottom;
		}
		
		override public function position(line:TextLine):void
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(line);
			var totalWidth:Number = getTotalSize(lp);
			
			switch(lp.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					positionLeft(line, totalWidth);
					break;
				case TextAlign.RIGHT:
					positionRight(line, totalWidth);
					break;
			}
		}
		
		private function positionLeft(line:TextLine, totalWidth:Number):void
		{
			var x:Number = target.majorDirection.value;
			
			if((x + line.specifiedWidth) >= totalWidth)
			{
				incrementY(line);
			}
			
			//Check to see if there's a line break at the end of this line.
			//If so, increment the Y regardless of the X position.
			else if(TextLineUtil.hasLineBreak(line))
			{
				incrementY(line);
			}
			else
			{
				line.y = y + line.ascent;
			}
		}
		
		private function positionRight(line:TextLine, totalWidth:Number):void
		{
		}
		
		private function incrementY(line:TextLine):void
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(line);
			var block:TextBlock = line.textBlock;
			
			y += line.ascent;
			line.y = y;
			y += line.descent + lp.leading;
		}
		
		override public function checkTargetBounds(line:TextLine):Boolean
		{
			if(super.checkTargetBounds(line))
			{
				y = 0;
				return true;
			}
			
			if(target.totalHeight < target.measuredHeight)
			{
				target.totalHeight = target.measuredHeight;
				
				if(target.scrollable)
				{
					return false;
				}
			}
			
			var eHeight:Number = target.explicitHeight;
			
			if(eHeight != eHeight)
				return false;
			
			if(line)
				return ((line.y + line.textHeight) >= (eHeight + engine.scrollPosition));
			
			return (y >= (eHeight + engine.scrollPosition));
		}
		
		override public function get value():Number
		{
			return y;
		}
	}
}
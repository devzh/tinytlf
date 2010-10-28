package org.tinytlf.layout.orientation.horizontal
{
	import flash.display.DisplayObject;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.IConstraintTextContainer;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.layout.properties.TextAlign;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextLineUtil;
	
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
			if(line)
			{
				if(target.hasLine(line))
				{
					y = line.y + line.textHeight;
				}
				return;
			}
			
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
//			lp.height = 0;
			
			if(lp.y)
				y = lp.y;
			
			y += lp.paddingTop;
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
			
			if(line === block.firstLine && !lp.y)
			{
				lp.y = y;
			}
			
			y += line.ascent;
			
			line.y = y;
			y += line.descent + lp.leading;
			lp.height += line.textHeight + lp.leading;
			target.measuredHeight = Math.max(target.measuredHeight, 
				target.measuredHeight + ((line.textHeight || 1) + lp.leading));
		}
		
		private var scrollHeight:Number = 0;
		
		override public function checkTargetBounds(line:TextLine):Boolean
		{
			if(super.checkTargetBounds(line))
			{
				y = 0;
				return true;
			}
			
			if(target.scrollable)
			{
				if(scrollHeight < target.measuredHeight)
				{
					scrollHeight = target.measuredHeight;
					return false;
				}
			}
			
			var eHeight:Number = target.explicitHeight;
			
			if(eHeight != eHeight)
				return false;
			
			return ((y + line.textHeight) >= (eHeight + engine.scrollPosition));
		}
		
		override public function get value():Number
		{
			return y;
		}
	}
}
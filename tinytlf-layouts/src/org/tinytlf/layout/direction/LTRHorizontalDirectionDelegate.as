package org.tinytlf.layout.direction
{
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.IFlowLayout;
	import org.tinytlf.layout.IFlowLayoutElement;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.layout.properties.TextFloat;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class LTRHorizontalDirectionDelegate extends DirectionDelegateBase
	{
		public function LTRHorizontalDirectionDelegate(target:IFlowLayout)
		{
			super(target);
		}
		
		override public function prepForTextBlock(block:TextBlock):void
		{
			super.prepForTextBlock(block);
			
			var props:LayoutProperties = getLayoutProperties(block);
			
			layoutPosition.x = 0;
			layoutPosition.y = target.measuredHeight;
			
			if(block.firstLine == null)
			{
				layoutPosition.x = props.textIndent;
				layoutPosition.y += props.paddingTop;
			}
		}
		
		override public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			return flow(super.getLineSize(block, previousLine), previousLine);
		}
		
		override public function layoutLine(latestLine:TextLine):void
		{
			super.layoutLine(latestLine);
			checkLayoutPositions(latestLine);
		}
		
		override public function checkTargetConstraints(latestLine:TextLine):Boolean
		{
			// This checks for container termination, so respect that first.
			if(super.checkTargetConstraints(latestLine))
			{
				layoutPosition.x = layoutPosition.y = 0;
				return true;
			}
			
			if(layout.explicitHeight !== layout.explicitHeight)
			{
				return false;
			}
			
			if((layoutPosition.y + latestLine.textHeight) >= layout.explicitHeight)
			{
				layoutPosition.x = layoutPosition.y = 0;
				return true;
			}
			
			return false;
		}
		
		override public function registerFlowElement(line:TextLine, atomIndex:int):Boolean
		{
			var retVal:Boolean = super.registerFlowElement(line, atomIndex);
			
			var contentElement:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
			if(contentElement.userData is Vector.<*>)
			{
				var elements:Vector.<IFlowLayoutElement> = layout.elements;
				
				var element:IFlowLayoutElement = elements[elements.length - 1];
				var lp:LayoutProperties = new LayoutProperties(layout.engine.styler.describeElement(contentElement.userData));
				var totalWidth:Number = getTotalSize(line.textBlock);
				
				switch(lp.float)
				{
					case TextFloat.LEFT:
						element.x = line.x = layoutPosition.x = 0;
						break;
					case TextFloat.CENTER:
						layoutPosition.x = line.x = (totalWidth - element.width) * 0.5;
						break;
					case TextFloat.RIGHT:
						layoutPosition.x = line.x = totalWidth - element.width;
						break;
				}
			}
			
			return retVal;
		}
		
		/**
		 * @private
		 * Calculates a suitable width for the next TextLine based on the total
		 * size of the container and the previous TextLine. Modifies the
		 * layoutPosition.x and returns the proper size of the TextLine.
		 */
		protected function flow(totalSize:Number, previousLine:TextLine):Number
		{
			var elements:Vector.<IFlowLayoutElement> = layout.elements;
			var element:IFlowLayoutElement;
			var line:TextLine;
			
			var size:Number = totalSize;
			var n:int = elements.length;
			var i:int = 0;
			
			for(i = 0; i < n; ++i)
			{
				element = elements[i];
				line = element.textLine;
				
				if(line.y >= layoutPosition.y && line.x < layoutPosition.x)
					continue;
				
				if(element.containsY(layoutPosition.y))
				{
					if(layoutPosition.x < element.x)
					{
						size = element.x - layoutPosition.x;
						break;
					}
					else if(layoutPosition.x >= (element.x + element.width))
					{
						size -= element.x;
					}
					else
					{
						size = totalSize - element.x - element.width;
						layoutPosition.x = element.x + element.width;
					}
				}
				
				//If the size ever drops to 0, reset it all and update the y.
				if(size <= 0)
				{
					size = totalSize;
					i = 0;
					layoutPosition.x = 0;
					
					//If we get here and there's no previous line,
					//we're probably flowing in a super tight space and don't
					//have room to create lines anyway. Returning 0 is all
					//we can do :|
					if(!previousLine)
						return 0;
					
					layoutPosition.y += previousLine.height;
				}
			}
			
			return size;
		}
		
		override protected function layoutX(line:TextLine):void
		{
			line.x = layoutPosition.x;
			layoutPosition.x += line.specifiedWidth;
		}
		
		override protected function layoutY(line:TextLine):void
		{
			var w:Number = getTotalSize(line.textBlock);
			if(layoutPosition.x >= (w - 10))
			{
				super.layoutY(line);
			}
			else
			{
				var elements:Vector.<IFlowLayoutElement> = layout.elements;
				var element:IFlowLayoutElement;
				
				var n:int = elements.length;
				
				for(var i:int = 0; i < n; ++i)
				{
					element = elements[i];
					
					if(element.containsY(layoutPosition.y))
					{
						if(layoutPosition.x == element.x)
						{
							line.y = line.ascent + layoutPosition.y;
							break;
						}
					}
					
					if(i == n)
						line.y = layoutPosition.y;
				}
			}
		}
		
		protected function checkLayoutPositions(line:TextLine):void
		{
			//If the X layout position has proceeded past the width of the 
			//TextBlock, reset him back to the left edge.
			var w:Number = getTotalSize(line.textBlock);
			if(layoutPosition.x >= (w - 10))
			{
				layoutPosition.x = 0;
			}
		}
	}
}

package org.tinytlf.layout.direction
{
	import flash.geom.Point;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	
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
		
		override public function preLayout():void
		{
			super.preLayout();
			
			layoutPosition.x = 0;
			layoutPosition.y = 0;
		}
		
		override public function prepForTextBlock(block:TextBlock, line:TextLine):void
		{
			super.prepForTextBlock(block, line);
			
			var props:LayoutProperties = getLayoutProperties(block);
			
			if(line)
			{
				if(line == block.firstLine)
				{
					layoutPosition.x = props.textIndent;
					layoutPosition.y += props.paddingTop;
				}
				
				return;
			}
			
			if(!block.firstLine)
			{
				layoutPosition.x = props.textIndent;
				layoutPosition.y += props.paddingTop;
			}
		}
		
		protected var layoutPosition:Point = new Point();
		
		override public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			return fitSizeWithinFloats(super.getLineSize(block, previousLine), previousLine);
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
						element.x = line.x = layoutPosition.x;// = 0;
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
		
		override protected function layoutX(line:TextLine):void
		{
			super.layoutX(line);
			
			var pt:Point = layoutPosition.clone();
			
			var elements:Vector.<IFlowLayoutElement> = layout.elements;
			var element:IFlowLayoutElement;
			
			var n:int = elements.length;
			
			for(var i:int = 0; i < n; ++i)
			{
				element = elements[i];
				
				if(element.textLine == line)
					continue;
				
				if(element.containsY(pt.y) && element.containsX(pt.x))
					pt.x = element.x + element.width;
			}
			
			line.x = layoutPosition.x = pt.x;
		}
		
		override protected function layoutY(line:TextLine):void
		{
			var w:Number = getTotalSize(line.textBlock);
			
			if(layoutPosition.x + line.specifiedWidth >= w)
			{
				layoutPosition.y += line.ascent;
				line.y = layoutPosition.y;
				layoutPosition.y += line.descent;
				
				layoutPosition.x = 0;
			}
			else
			{
				var pt:Point = layoutPosition.clone();
				var elements:Vector.<IFlowLayoutElement> = layout.elements;
				var element:IFlowLayoutElement;
				var n:int = elements.length;
				
				for(var i:int = 0; i < n; ++i)
				{
					element = elements[i];
					
					if(element.textLine === line)
						continue;
					
					if(element.containsY(pt.y))
					{
						if(pt.x <= element.x)
						{
							line.y = line.ascent + layoutPosition.y;
							layoutPosition.y += line.textHeight;
							break;
						}
					}
				}
				
				if(i == n)
				{
					line.y = line.ascent + layoutPosition.y;
					layoutPosition.y += line.textHeight;
				}
			}
		}
		
		protected function fitSizeWithinFloats(totalSize:Number, line:TextLine):Number
		{
			var size:Number = totalSize;
			
			var pt:Point = layoutPosition.clone();
			pt.x = 0;
			
			var elements:Vector.<IFlowLayoutElement> = layout.elements;
			var n:int = elements.length;
			var element:IFlowLayoutElement;
			
			for(var i:int = 0; i < n; ++i)
			{
				element = elements[i];
				
				if(element.containsY(pt.y))
				{
					if(element.containsX(pt.x))
					{
						size -= /*totalSize - */(element.x + element.width);
						pt.x = element.x - element.width + 1;
					}
					else if(pt.x < element.x)
					{
						size -= element.width;
					}
				}
				
				if(size < 0)
				{
					if(line)
					{
						size = totalSize;
						pt = layoutPosition.clone();
						pt.y += line.height;
						pt.x = 0;
						i = 0;
						line = null;
					}
					else
					{
						return 0;
					}
				}
			}
			
			return size;
		}
	}
}

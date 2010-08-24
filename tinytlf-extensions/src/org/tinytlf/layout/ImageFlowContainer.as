package org.tinytlf.layout
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	public class ImageFlowContainer extends TextContainerBase
	{
		public function ImageFlowContainer(container:DisplayObjectContainer, explicitWidth:Number = NaN, explicitHeight:Number = NaN)
		{
			super(container, explicitWidth, explicitHeight);
		}
		
		override public function recreateTextLine(line:TextLine):TextLine
		{
			line = super.recreateTextLine(line);
			
			associateGraphics(line);
			
			return line;
		}
		
		override protected function createAndLayoutLine(block:TextBlock, previousLine:TextLine):TextLine
		{
			var line:TextLine = super.createAndLayoutLine(block, previousLine);
			
			if(!line)
				return null;
			
			associateGraphics(line);
			
			return line;
		}
		
		protected var graphics:Dictionary = new Dictionary(false);
		
		override protected function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			var size:Number = super.getLineSize(block, previousLine);
			
			var rect:Rectangle;
			for (var tmp:* in graphics)
			{
				rect = Rectangle(tmp);
				if (rect.contains(rect.x + 1, layoutPosition.y))
				{
					if (layoutPosition.x < rect.x)
					{
						size = rect.x;
						layoutPosition.x = 0;
					}
					else
					{
						layoutPosition.x = rect.x + rect.width;
						size -= layoutPosition.x;
					}
					
					break;
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
			if ((layoutPosition.x + line.width) > w)
			{
				layoutPosition.x = 0;
				super.layoutY(line);
			}
			else if(line.x == 0)
			{
				layoutPosition.y += line.ascent;
				line.y = layoutPosition.y;
				layoutPosition.y -= line.ascent;
			}
			else
			{
				line.y = layoutPosition.y;
			}
		}
		
		override protected function unregisterLine(line:TextLine):void
		{
			super.unregisterLine(line);
			for (var tmp:* in graphics)
				if (graphics[tmp] === line)
					delete graphics[tmp];
		}
		
		protected function associateGraphics(line:TextLine):void
		{
			if (line.hasGraphicElement)
			{
				var rect:Rectangle;
				var n:int = line.atomCount;
				for (var i:int = 0; i < n; ++i)
				{
					if (line.getAtomGraphic(i))
					{
						rect = line.getAtomBounds(i);
						rect.offset(line.x, line.y);
						graphics[rect] = line;
					}
				}
			}
		}
	}
}
package org.tinytlf.layout
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.styles.IStyleAware;
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.util.fte.TextLineUtil;
	import org.tinytlf.layout.properties.LayoutProperties;
	
	public class ImageFlowContainer extends TextContainerBase
	{
		public function ImageFlowContainer(container:Sprite, 
										   explicitWidth:Number = NaN, explicitHeight:Number = NaN)
		{
			super(container, explicitWidth, explicitHeight);
		}
		
		override public function recreateTextLine(line:TextLine):TextLine
		{
			line = super.recreateTextLine(line);
			
			if (!line)
				return null;
			
			associateGraphics(line);
			
			return line;
		}
		
		override protected function createAndLayoutLine(block:TextBlock, previousLine:TextLine):TextLine
		{
			var line:TextLine = super.createAndLayoutLine(block, previousLine);
			
			if (!line)
				return null;
			
			associateGraphics(line);
			
			return line;
		}
		
		protected var graphics:Vector.<LayoutElement> = new <LayoutElement>[];
		
		override protected function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			var size:Number = super.getLineSize(block, previousLine);
			
			var totalSize:Number = size;
			var n:int = graphics.length;
			var layout:LayoutElement;
			var line:TextLine;
			
			for (var i:int = 0; i < n; ++i)
			{
				layout = graphics[i];
				line = layout.associatedLine;
				
				if(line.y >= layoutPosition.y)
					continue;
				
				if(layout.containsY(layoutPosition.y))
				{
					if(layoutPosition.x < layout.x)
					{
						size = layout.x - layoutPosition.x;
						break;
					}
					else if(layoutPosition.x >= (layout.x + layout.width))
					{
						size -= layout.x;
					}
					else
					{
						size = totalSize - layout.x - layout.width;
						layoutPosition.x = layout.x + layout.width;
					}
				}
				
				//If the size ever drops to 0, reset it all and update the y.
				if(size <= 0)
				{
					size = totalSize;
					i = 0;
					layoutPosition.x = 0;
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
			if (layoutPosition.x >= (w - 10))
			{
				layoutPosition.x = 0;
				super.layoutY(line);
			}
			else
			{
				var n:int = graphics.length;
				var layout:LayoutElement;
				
				for (var i:int = 0; i < n; ++i)
				{
					layout = graphics[i];
					
					if (layout.containsY(layoutPosition.y))
					{
						if(layoutPosition.x == layout.x)
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
		
		override protected function unregisterLine(line:TextLine):void
		{
			super.unregisterLine(line);
			
			var n:int = graphics.length;
			var tmp:Vector.<LayoutElement> = graphics.concat();
			
			for(var i:int = 0; i < n; ++i)
				if(graphics[i].associatedLine === line)
					tmp.splice(tmp.indexOf(graphics[i]), 1);
			
			graphics = tmp;
		}
		
		protected function associateGraphics(line:TextLine):void
		{
			if (line.hasGraphicElement)
			{
				var rect:Rectangle;
				var n:int = line.atomCount;
				var graphic:DisplayObject;
				var layout:LayoutElement;
				var element:ContentElement;
				
				for (var i:int = 0; i < n; ++i)
				{
					graphic = line.getAtomGraphic(i);
					if (graphic)
					{
						element = TextLineUtil.getElementAtAtomIndex(line, i);
						layout = new LayoutElement(line, i);
						graphics.push(layout);
					}
				}
				
				graphics.sort(function(p1:LayoutElement, p2:LayoutElement):int{
					return p1.x - p2.x;
				});
			}
		}
		
		override protected function getLayoutProperties(element:*):LayoutProperties
		{
			if(!(element is Array))
				return super.getLayoutProperties(element);
			
			var style:IStyleAware = new StyleAwareActor(engine.styler.describeElement(element));
			return new LayoutProperties(style);
		}
	}
}
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.text.engine.TextLine;

internal class LayoutElement
{
	public var associatedLine:TextLine;
	
	private var rect:Rectangle;
	
	public function LayoutElement(line:TextLine, atomIndex:int):void
	{
		rect = line.getAtomBounds(atomIndex);
		rect.offset(line.x, line.y);
		rect.x = Math.round(rect.x);
		rect.y = Math.round(rect.y);
		rect.width = Math.round(rect.width);
		rect.height = Math.round(rect.height);
		associatedLine = line;
	}
	
	public function get x():Number
	{
		return rect.x;
	}
	
	public function get y():Number
	{
		return rect.y;
	}
	
	public function get width():Number
	{
		return rect.width;
	}
	
	public function get height():Number
	{
		return rect.height;
	}
	
	public function containsX(hasX:Number):Boolean
	{
		return hasX > x && hasX < (x + width);
	}
	
	public function containsY(hasY:Number):Boolean
	{
		return hasY > y && hasY < (y + height);
	}
	
	public function getLayoutX(currentX:Number):Number
	{
		if(currentX < x)
			return currentX;
		
		if(containsX(currentX))
			return x + width;
		
		return currentX;
	}
	
	public function getLayoutY(currentY:Number):Number
	{
		if(currentY < y)
			return currentY;
		
		if(containsY(currentY))
			return y + height;
		
		return currentY;
	}
}
package org.tinytlf.layout.progression
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	
	public class LTRProgressor implements IProgressor
	{
		public function progress(rect:TextRectangle, previousItem:*):Number
		{
			if(rect is SectorPane && previousItem is SectorRow)
				return SectorRow(previousItem).x + SectorRow(previousItem).size;
			
			if(!previousItem)
				return rect.paddingLeft;
			
			if(previousItem is TextLine)
				return TextLine(previousItem).y + TextLine(previousItem).descent + rect.leading || 0;
			
			return 0;
		}
		
		public function getTotalHorizontalSize(rect:TextRectangle):Number
		{
			var w:Number = rect.paddingLeft;
			
			rect.
				textLines.
				forEach(function(line:TextLine, i:int, a:Array):void{
				w += line.totalHeight;
				
				if(i < a.length - 1)
					w += rect.leading;
			});
			
			return w + rect.paddingRight;
		}
		
		public function getTotalVerticalSize(rect:TextRectangle):Number
		{
			var h:Number = 0;
			rect.
				textLines.
				forEach(function(line:TextLine, ... args):void{
				h = Math.max(h, line.width);
			});
			return rect.paddingTop + h + rect.paddingBottom;
		}
	}
}
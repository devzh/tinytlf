package org.tinytlf.layout.progression
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	
	public class TTBProgressor implements IProgressor
	{
		public function progress(rect:TextRectangle, previousItem:*):Number
		{
			if(rect is TextPane && previousItem is SectorRow)
				return SectorRow(previousItem).y + SectorRow(previousItem).size;
			
			if(!previousItem)
				return rect.paddingTop;
			
			if(previousItem is TextLine)
				return TextLine(previousItem).y + TextLine(previousItem).descent + rect.leading || 0;
			
			return 0;
		}
		
		public function getTotalHorizontalSize(rect:TextRectangle):Number
		{
			var w:Number = 0;
			rect.
				children.
				forEach(function(line:TextLine, ... args):void{
				w = Math.max(w, line.width);
			});
			return rect.paddingLeft + w + rect.paddingRight || 0;
		}
		
		public function getTotalVerticalSize(rect:TextRectangle):Number
		{
			var h:Number = rect.paddingTop;
			rect.
				children.
				forEach(function(line:TextLine, i:int, a:Array):void{
				h += line.totalHeight;
				
				if(i < a.length - 1)
					h += rect.leading;
			});
			
			return h + rect.paddingBottom || 0;
		}
	}
}
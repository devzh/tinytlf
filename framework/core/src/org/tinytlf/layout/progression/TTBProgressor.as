package org.tinytlf.layout.progression
{
	import flash.text.engine.*;
	import org.tinytlf.layout.*;
	
	public class TTBProgressor implements IBlockProgressor
	{
		public function progress(region:TextSector, previousLine:TextLine):Number
		{
			if(!previousLine)
				return region.paddingTop;
			
			return previousLine.y + previousLine.descent + region.leading || 0;
		}
		
		public function getTotalHorizontalSize(region:TextSector, lines:Array):Number
		{
			var w:Number = 0;
			lines.forEach(function(line:TextLine, ... args):void{
				w = Math.max(w, line.width);
			});
			return region.paddingLeft + w + region.paddingRight || 0;
		}
		
		public function getTotalVerticalSize(region:TextSector, lines:Array):Number
		{
			var h:Number = region.paddingTop;
			
			lines.forEach(function(line:TextLine, i:int, a:Array):void{
				h += line.totalHeight;
				
				if(i < a.length - 1)
					h += region.leading;
			});
			
			return h + region.paddingBottom || 0;
		}
	}
}
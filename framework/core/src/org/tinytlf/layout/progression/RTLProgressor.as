package org.tinytlf.layout.progression
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	
	public class RTLProgressor implements IProgressor
	{
		public function progress(region:TextSector, previousLine:TextLine):Number
		{
			if(!previousLine)
				return region.width - region.paddingRight;
			
			return previousLine.y - previousLine.ascent - region.leading;
		}
		
		public function getTotalHorizontalSize(region:TextSector, lines:Array):Number
		{
			var w:Number = region.paddingLeft;
			
			lines.forEach(function(line:TextLine, i:int, a:Array):void{
				w += line.totalHeight;
				
				if(i < a.length - 1)
					w += region.leading;
			});
			
			return w + region.paddingRight;
		}
		
		public function getTotalVerticalSize(region:TextSector, lines:Array):Number
		{
			var h:Number = 0;
			lines.forEach(function(line:TextLine, ... args):void{
				h = Math.max(h, line.width);
			});
			return region.paddingTop + h + region.paddingBottom;
		}
	}
}
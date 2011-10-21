package org.tinytlf.layout.progression
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.rect.*;
	import org.tinytlf.layout.rect.sector.*;
	
	public class TTBProgression implements IProgression
	{
		public function getLineSize(rect:TextRectangle, previousLine:TextLine):Number
		{
			const indent:Number = ((!previousLine && rect is TextSector) ? TextSector(rect).textIndent : 0) || 0;
			
			return rect.textAlign == TextAlign.JUSTIFY ?
				rect.width - rect.paddingLeft - rect.paddingRight - indent :
				a.getLineSize(rect, previousLine);
		}
		
		public function position(rect:TextRectangle, child:DisplayObject):void
		{
			if(child is TextLine)
			{
				positionLine(rect, child as TextLine);
				return;
			}
			
			child.y = rect.y;
			child.x = rect.textAlign == TextAlign.JUSTIFY ?
				defaultAlignment.getAlignment(rect, child) :
				a.getAlignment(rect, child);
		}
		
		protected function positionLine(rect:TextRectangle, line:TextLine):void
		{
			const pline:TextLine = line.previousLine;
			
			if(pline)
				line.y = (pline.y + pline.descent + rect.leading + line.ascent) || 0;
			else
				line.y = rect.paddingTop + line.ascent;
			
			line.x = rect.textAlign == TextAlign.JUSTIFY ?
				defaultAlignment.getAlignment(rect, line) :
				a.getAlignment(rect, line);
		}
		
		public function getTotalHorizontalSize(rect:TextRectangle):Number
		{
			var w:Number = 0;
			rect.
				children.
				forEach(function(line:TextLine, ... args):void {
					w = Math.max(w, line.width);
				});
			return rect.paddingLeft + w + rect.paddingRight || 0;
		}
		
		public function getTotalVerticalSize(rect:TextRectangle):Number
		{
			var h:Number = rect.paddingTop;
			rect.
				children.
				forEach(function(line:TextLine, i:int, a:Array):void {
					h += line.totalHeight;
					
					if(i < a.length - 1)
						h += rect.leading;
				});
			
			return h + rect.paddingBottom || 0;
		}
		
		protected var a:IAlignment = new LeftAlignment();
		public function get alignment():IAlignment
		{
			return a;
		}
		
		public function set alignment(value:IAlignment):void
		{
			a = value;
		}
		
		protected var defaultAlignment:IAlignment = new LeftAlignment();
	}
}

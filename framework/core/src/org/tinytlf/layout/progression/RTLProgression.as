package org.tinytlf.layout.progression
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.rect.*;
	import org.tinytlf.layout.rect.sector.*;
	
	public class RTLProgression implements IProgression
	{
		public function getLineSize(rect:TextRectangle, previousLine:TextLine):Number
		{
			const indent:Number = ((!previousLine && rect is TextSector) ? TextSector(rect).textIndent : 0) || 0;
			
			return rect.textAlign == TextAlign.JUSTIFY ?
				rect.height - rect.paddingTop - rect.paddingBottom - indent :
				a.getLineSize(rect, previousLine);
		}
		
		public function position(rect:TextRectangle, child:DisplayObject):void
		{
			if(child is TextLine)
			{
				positionLine(rect, child as TextLine);
				return;
			}
			
			child.x = rect.x + (rect.width - child.width);
			child.y = rect.textAlign == TextAlign.JUSTIFY ?
				defaultAlignment.getAlignment(rect, child) :
				a.getAlignment(rect, child);
		}
		
		protected function positionLine(rect:TextRectangle, line:TextLine):void
		{
			const pline:TextLine = line.previousLine;
			
			if(pline)
				line.x = pline.x - rect.leading - line.width;
			else
				line.x = -rect.paddingRight - line.width;
			
			line.y = rect.textAlign == TextAlign.JUSTIFY ?
				defaultAlignment.getAlignment(rect, line) :
				a.getAlignment(rect, line);
		}
		
		public function getTotalHorizontalSize(rect:TextRectangle):Number
		{
			var w:Number = rect.paddingLeft;
			
			rect.
				children.
				forEach(function(line:TextLine, i:int, a:Array):void {
					w += line.width;
					
					if(i < a.length - 1)
						w += rect.leading;
				});
			
			return w + rect.paddingRight;
		}
		
		public function getTotalVerticalSize(rect:TextRectangle):Number
		{
			var h:Number = 0;
			rect.
				children.
				forEach(function(line:TextLine, ... args):void {
					h = Math.max(h, line.height);
				});
			return rect.paddingTop + h + rect.paddingBottom;
		}
		
		protected var a:IAlignment = new TopAlignment();
		public function get alignment():IAlignment
		{
			return a;
		}
		
		public function set alignment(value:IAlignment):void
		{
			a = value;
		}
		
		protected var defaultAlignment:IAlignment = new TopAlignment();
	}
}

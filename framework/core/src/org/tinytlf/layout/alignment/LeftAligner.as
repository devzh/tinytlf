package org.tinytlf.layout.alignment
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.sector.*;
	
	public class LeftAligner extends AlignerBase
	{
		override public function getSize(rect:TextRectangle, previousItem:* = null):Number
		{
			const indent:Number = ((rect is TextSector) ? TextSector(rect).textIndent : 0) || 0;
			
			if(previousItem is TextRectangle)
				return rect.width;
			
			return (rect.width - rect.paddingLeft - rect.paddingRight) -
				((previousItem == null) ? indent : 0);
		}
		
		override public function getStart(rect:TextRectangle, thisItem:*):Number
		{
			var x:Number = rect.paddingLeft;
			const indent:Number = (rect is TextSector) ? TextSector(rect).textIndent : 0;
			
			if(!thisItem || (thisItem is TextLine && TextLine(thisItem).previousLine == null))
				x += indent;
			
			return x;
		}
		
		override public function sort(items:Array):Array
		{
			items = items.concat();
			items.sort(function(l1:TextLine, l2:TextLine):int{
				return l1.y - l2.y;
			});
			return items;
		}
	}
}

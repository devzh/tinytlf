package org.tinytlf.layout.alignment
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.sector.*;
	
	public class RightAligner extends AlignerBase
	{
		override public function getSize(rect:TextRectangle, previousItem:* = null):Number
		{
			if(previousItem is TextRectangle)
				return rect.width;
			
			return rect.width - rect.paddingLeft - rect.paddingRight;
		}
		
		override public function getStart(rect:TextRectangle, thisItem:*):Number
		{
			return rect.width - thisItem.width - rect.paddingRight;
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

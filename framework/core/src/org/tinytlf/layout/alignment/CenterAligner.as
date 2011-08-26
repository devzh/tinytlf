package org.tinytlf.layout.alignment
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.sector.*;
	
	public class CenterAligner extends AlignerBase
	{
		override public function getSize(region:TextRectangle, previousItem:* = null):Number
		{
			return region.width - region.paddingLeft - region.paddingRight;
		}
		
		override public function getStart(region:TextRectangle, thisItem:*):Number
		{
			return (getSize(region, null) - TextLine(thisItem).width) * 0.5;
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
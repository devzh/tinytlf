package org.tinytlf.layout.alignment
{
	import org.tinytlf.layout.sector.*;

	public interface IAligner
	{
		function getSize(rect:TextRectangle, previousItem:* = null):Number;
		
		function getStart(rect:TextRectangle, thisItem:*):Number;
		
		function sort(items:Array):Array;
	}
}
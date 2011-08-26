package org.tinytlf.layout.progression
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.sector.*;
	
	public interface IProgressor
	{
		function progress(rect:TextRectangle, previousItem:*):Number;
		
		function getTotalHorizontalSize(rect:TextRectangle):Number;
		
		function getTotalVerticalSize(rect:TextRectangle):Number;
	}
}
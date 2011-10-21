package org.tinytlf.layout.progression
{
	import flash.display.DisplayObject;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.alignment.IAlignment;
	import org.tinytlf.layout.rect.*;
	
	public interface IProgression
	{
		function get alignment():IAlignment;
		function set alignment(value:IAlignment):void;
		
		function getLineSize(rect:TextRectangle, previousLine:TextLine):Number;
		
		function position(rect:TextRectangle, child:DisplayObject):void;
		
		function getTotalHorizontalSize(rect:TextRectangle):Number;
		
		function getTotalVerticalSize(rect:TextRectangle):Number;
	}
}
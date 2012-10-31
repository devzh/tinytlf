package org.tinytlf.layout.alignment
{
	import flash.display.DisplayObject;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.rect.*;

	public interface IAlignment
	{
		function getLineSize(rect:TextRectangle, previousLine:TextLine):Number;
		
		function getAlignment(rect:TextRectangle, child:DisplayObject):Number;
	}
}
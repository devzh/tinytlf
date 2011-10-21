package org.tinytlf.layout.alignment
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.rect.*;
	
	public class MiddleAlignment implements IAlignment
	{
		public function getLineSize(rect:TextRectangle, previousLine:TextLine):Number
		{
			return rect.height - rect.paddingTop - rect.paddingBottom;
		}
		
		public function getAlignment(rect:TextRectangle, line:DisplayObject):Number
		{
			return (rect.height - line.height) * 0.5;
		}
	}
}
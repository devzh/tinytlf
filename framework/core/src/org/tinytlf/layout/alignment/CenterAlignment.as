package org.tinytlf.layout.alignment
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.rect.*;
	
	public class CenterAlignment implements IAlignment
	{
		public function getLineSize(rect:TextRectangle, previousLine:TextLine):Number
		{
			return rect.width - rect.paddingLeft - rect.paddingRight;
		}
		
		public function getAlignment(rect:TextRectangle, line:DisplayObject):Number
		{
			return (rect.width - line.width) * 0.5;
		}
	}
}
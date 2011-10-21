package org.tinytlf.layout.alignment
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.rect.*;
	import org.tinytlf.layout.rect.sector.*;
	
	public class RightAlignment extends Alignment implements IAlignment
	{
		public function getLineSize(rect:TextRectangle, previousLine:TextLine):Number
		{
			return rect.width - rect.paddingLeft - rect.paddingRight - getIndent(rect, previousLine);
		}
		
		public function getAlignment(rect:TextRectangle, line:DisplayObject):Number
		{
			return rect.width - line.width - rect.paddingRight - getIndent(rect, line);
		}
	}
}

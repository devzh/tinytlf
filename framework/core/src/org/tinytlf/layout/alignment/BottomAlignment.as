package org.tinytlf.layout.alignment
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.rect.*;
	import org.tinytlf.layout.rect.sector.*;
	
	public class BottomAlignment extends Alignment implements IAlignment
	{
		public function getLineSize(rect:TextRectangle, previousLine:TextLine):Number
		{
			return rect.height - rect.paddingTop - rect.paddingBottom - getIndent(rect, previousLine);
		}
		
		public function getAlignment(rect:TextRectangle, line:DisplayObject):Number
		{
			return rect.height - line.height - rect.paddingBottom - getIndent(rect, line);
		}
	}
}

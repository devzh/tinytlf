package org.tinytlf.layout.alignment
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.rect.*;
	import org.tinytlf.layout.rect.sector.*;

	internal class Alignment
	{
		protected function getIndent(rect:TextRectangle, child:DisplayObject):Number
		{
			if(!(rect is TextSector))
				return 0;
			
			if(!child)
				rect['textIndent'];
			
			if(!(child is TextLine))
				return 0;
			
			return (child as TextLine).previousLine ? 0 : rect['textIndent'];
		}
	}
}
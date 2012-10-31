package org.tinytlf.layout.box.alignment
{
	import flash.display.DisplayObject;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.box.*;

	public interface IAlignment
	{
		function getLineSize(box:Box, previousLine:TextLine):Number;
		
		function getAlignment(box:Box, child:DisplayObject):Number;
	}
}
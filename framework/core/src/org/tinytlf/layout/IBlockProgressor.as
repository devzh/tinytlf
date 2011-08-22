package org.tinytlf.layout
{
	import flash.text.engine.*;
	
	public interface IBlockProgressor
	{
		function progress(region:TextSector, previousLine:TextLine):Number;
		
		function getTotalHorizontalSize(region:TextSector, lines:Array):Number;
		
		function getTotalVerticalSize(region:TextSector, lines:Array):Number;
	}
}
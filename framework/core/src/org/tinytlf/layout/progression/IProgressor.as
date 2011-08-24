package org.tinytlf.layout.progression
{
	import flash.text.engine.*;
	import org.tinytlf.layout.sector.TextSector;
	
	public interface IProgressor
	{
		function progress(region:TextSector, previousLine:TextLine):Number;
		
		function getTotalHorizontalSize(region:TextSector, lines:Array):Number;
		
		function getTotalVerticalSize(region:TextSector, lines:Array):Number;
	}
}
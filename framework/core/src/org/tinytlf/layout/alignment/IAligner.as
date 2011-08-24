package org.tinytlf.layout.alignment
{
	import org.tinytlf.layout.sector.TextSector;

	public interface IAligner
	{
		function getSize(region:TextSector, previousItem:*):Number;
		
		function getStart(region:TextSector, thisItem:*):Number;
		
		function sort(items:Array):Array;
	}
}
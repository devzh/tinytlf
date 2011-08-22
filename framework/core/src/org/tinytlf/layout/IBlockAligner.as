package org.tinytlf.layout
{
	public interface IBlockAligner
	{
		function getSize(region:TextSector, previousItem:*):Number;
		
		function getStart(region:TextSector, thisItem:*):Number;
		
		function sort(items:Array):Array;
	}
}
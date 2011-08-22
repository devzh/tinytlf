package org.tinytlf.layout
{
	public interface IBlockLayout
	{
		function set aligner(value:IBlockAligner):void;
		
		function set progressor(value:IBlockProgressor):void;
		
		function layout(lines:Array,
						region:TextSector = null,
						constraints:Array = null):Array/*<TextLine>*/;
	}
}
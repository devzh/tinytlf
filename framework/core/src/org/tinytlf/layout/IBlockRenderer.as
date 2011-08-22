package org.tinytlf.layout
{
	import flash.text.engine.*;
	
	public interface IBlockRenderer
	{
		function set aligner(value:IBlockAligner):void;
		
		function set progressor(value:IBlockProgressor):void;
		
		function render(block:TextBlock,
						region:TextSector = null,
						constraints:Array = null):Array/*<TextLine>*/;
	}
}
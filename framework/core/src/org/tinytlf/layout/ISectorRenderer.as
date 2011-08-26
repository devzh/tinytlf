package org.tinytlf.layout
{
	import flash.text.engine.*;
	import org.tinytlf.layout.alignment.IAligner;
	import org.tinytlf.layout.progression.IProgressor;
	import org.tinytlf.layout.sector.TextSector;
	
	public interface ISectorRenderer
	{
		function set aligner(value:IAligner):void;
		
		function set progressor(value:IProgressor):void;
		
		function render(block:TextBlock, sector:TextSector):Array/*<TextLine>*/;
	}
}
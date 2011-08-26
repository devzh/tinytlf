package org.tinytlf.layout
{
	import org.tinytlf.layout.alignment.IAligner;
	import org.tinytlf.layout.progression.IProgressor;
	import org.tinytlf.layout.sector.TextSector;

	public interface ISectorLayout
	{
		function set aligner(value:IAligner):void;
		
		function set progressor(value:IProgressor):void;
		
		function layout(lines:Array, sector:TextSector):Array/*<TextLine>*/;
	}
}
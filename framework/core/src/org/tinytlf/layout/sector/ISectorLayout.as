package org.tinytlf.layout.sector
{
	import org.tinytlf.layout.alignment.IAligner;
	import org.tinytlf.layout.progression.IProgressor;

	public interface ISectorLayout
	{
		function set aligner(value:IAligner):void;
		
		function set progressor(value:IProgressor):void;
		
		function layout(lines:Array, region:TextSector = null):Array/*<TextLine>*/;
	}
}
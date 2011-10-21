package org.tinytlf.layout.rect.sector
{
	import org.tinytlf.layout.alignment.IAlignment;
	import org.tinytlf.layout.progression.IProgression;

	public interface ISectorLayout
	{
		function get progression():IProgression;
		function set progression(value:IProgression):void;
		
		function layout(lines:Array, sector:TextSector):Array/*<TextLine>*/;
	}
}
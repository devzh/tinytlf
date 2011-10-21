package org.tinytlf.layout.rect.sector
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.alignment.IAlignment;
	import org.tinytlf.layout.progression.IProgression;
	
	public interface ISectorRenderer
	{
		function get progression():IProgression;
		function set progression(value:IProgression):void;
		
		function render(block:TextBlock, sector:TextSector, existingLines:Array = null):Array/*<TextLine>*/;
	}
}
package org.tinytlf.interaction.behaviors.keyboard.selection
{
	import flash.events.Event;
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;
	import org.tinytlf.interaction.behaviors.Behavior;
	
	public class SelectAllBehavior extends Behavior
	{
		override protected function onSelectAll(event:Event):void
		{
			super.onSelectAll(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event);
			if(!info)
				return;
			
			var engine:ITextEngine = info.engine;
			var blocks:Vector.<TextBlock> = engine.layout.textBlockFactory.blocks;
			var len:int = 0;
			var n:int = blocks.length;
			for(var i:int = 0; i < n; ++i)
			{
				len += blocks[i].content.rawText.length;
			}
			
			engine.select(0, len);
		}
	}
}
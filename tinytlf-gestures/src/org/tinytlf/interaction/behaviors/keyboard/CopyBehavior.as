package org.tinytlf.interaction.behaviors.keyboard
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;
	import org.tinytlf.interaction.behaviors.Behavior;
	
	public class CopyBehavior extends Behavior
	{
		override protected function onCopy(event:Event):void
		{
			super.onCopy(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event);
			if(!info)
				return;
			
			var engine:ITextEngine = info.engine;
			var selection:Point = engine.selection;
			
			//super fast inline isNaN checks
			if(selection.x != selection.x || selection.y != selection.y)
				return;
			
			var blocks:Vector.<TextBlock> = engine.layout.textBlockFactory.blocks;
			
			var str:String = '';
			var n:int = blocks.length;
			for(var i:int = 0; i < n; ++i)
			{
				str += blocks[i].content.rawText;
				if(i < n-1)
					str += '\n';
			}
			
			str = str.replace(/﷯+/g, function(...args):String{
				selection.y -= args[0].length - 1;
				return ' ';
			});
			
			selection.y += blocks.length;
			
			var copyString:String = str.substring(Math.max(selection.x - 1, 0), Math.min(selection.y, str.length));
			System.setClipboard(copyString);
		}
	}
}
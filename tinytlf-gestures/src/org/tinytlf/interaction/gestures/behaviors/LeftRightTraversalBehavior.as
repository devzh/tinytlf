package org.tinytlf.interaction.gestures.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.system.System;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;
	import org.tinytlf.util.FTEUtil;

	public class LeftRightTraversalBehavior extends Behavior
	{
		public function LeftRightTraversalBehavior()
		{
			super();
		}
		
		override protected function onKeyDown(event:KeyboardEvent):void
		{
			super.onKeyDown(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event);
			
			if(!info)
				return;
			
			var engine:ITextEngine = info.engine;
			var line:TextLine = info.line;
			var block:TextBlock= line.textBlock;
			var caretIndex:int = engine.caretIndex;
			var blockPosition:int = engine.getBlockPosition(block);
			
			var direction:int = event.keyCode == Keyboard.LEFT ? -1 : 1;
			
			//TODO: Somehow check for PC/Mac here and do the right thing.
			//I hate the poor system integration in Flash text.
			if(event.ctrlKey)
			{
				var atomIndex:int = caretIndex - blockPosition - line.textBlockBeginIndex;
				caretIndex = line.getAtomTextBlockBeginIndex(
					FTEUtil.getAtomWordBoundary(line, atomIndex, direction < 0))
					+ blockPosition;
			}
			else
			{
				caretIndex += direction;
			}
			
			engine.caretIndex = caretIndex;
		}
	}
}
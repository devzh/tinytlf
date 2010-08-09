package org.tinytlf.interaction.gestures.behaviors.keyboard.selection
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.engine.*;
	import flash.ui.Keyboard;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;
	import org.tinytlf.interaction.gestures.behaviors.Behavior;
	import org.tinytlf.util.FTEUtil;
	
	public class WordLeftRightBehavior extends Behavior
	{
		override protected function onKeyDown(event:KeyboardEvent):void
		{
			super.onKeyDown(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event);
			
			if (!info)
				return;
			
			var engine:ITextEngine = info.engine;
			var line:TextLine = info.line;
			var block:TextBlock = line.textBlock;
			var caretIndex:int = engine.caretIndex;
			var blockPosition:int = engine.getBlockPosition(block);
			
			var direction:int = event.keyCode == Keyboard.LEFT ? -1 : 1;
			
			var selection:Point = engine.selection.clone();
			if (isNaN(selection.x))
				selection.x = caretIndex;
			if (isNaN(selection.y))
				selection.y = caretIndex;
			
			var oldCaretIndex:int = caretIndex;
			var atomIndex:int = caretIndex - blockPosition - line.textBlockBeginIndex;
			
			if (direction < 0)
				atomIndex += direction;
			
			caretIndex = line.getAtomTextBlockBeginIndex(FTEUtil.getAtomWordBoundary(line, atomIndex, direction < 0)) + blockPosition;
			
			if (oldCaretIndex == caretIndex)
				caretIndex += direction;
			else if (direction > 0)
				caretIndex += 1;
			
			if (event.shiftKey)
			{
				if (direction < 0)
				{
					if (caretIndex < selection.x)
						selection.x = caretIndex;
					else
						selection.y = caretIndex;
				}
				else if (direction > 0)
				{
					if (caretIndex > selection.y)
						selection.y = caretIndex - 1;
					else
						selection.x = caretIndex;
				}
				
				engine.select(selection.x, selection.y);
			}
			else
			{
				engine.select();
			}
			
			engine.caretIndex = caretIndex;
		}
	}
}
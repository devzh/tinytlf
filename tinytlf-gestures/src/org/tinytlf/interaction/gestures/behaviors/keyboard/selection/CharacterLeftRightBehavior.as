package org.tinytlf.interaction.gestures.behaviors.keyboard.selection
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;
	import org.tinytlf.interaction.gestures.behaviors.Behavior;

	public class CharacterLeftRightBehavior extends Behavior
	{
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
			
			var selection:Point = engine.selection.clone();
			if(isNaN(selection.x))
				selection.x = caretIndex;
			if(isNaN(selection.y))
				selection.y = caretIndex;
			
			caretIndex += direction;
			
			if(event.shiftKey)
			{
				if(direction < 0)
				{
					if(caretIndex < selection.x)
						selection.x = caretIndex;
					else if(caretIndex == selection.x)
					{
						selection.x = NaN;
						selection.y = NaN;
					}
					else
						selection.y = caretIndex;
				}
				else if(direction > 0)
				{
					if(caretIndex > selection.y)
						selection.y = caretIndex - 1;
					else if(caretIndex == selection.y)
					{
						selection.x = NaN;
						selection.y = NaN;
					}
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
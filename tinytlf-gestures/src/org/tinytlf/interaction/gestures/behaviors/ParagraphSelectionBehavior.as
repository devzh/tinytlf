package org.tinytlf.interaction.gestures.behaviors
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;

	public class ParagraphSelectionBehavior extends Behavior
	{
		private var selectionBegin:Point = new Point();
		
		override protected function onMouseDown(event:MouseEvent):void
		{
			super.onMouseDown(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event);
			
			if(!info)
				return;
			
			var engine:ITextEngine = info.engine;
			var line:TextLine = info.line;
			var begin:int = engine.getBlockPosition(line.textBlock);
			var end:int = begin + engine.getBlockSize(line.textBlock) - 1;
			
			selectionBegin.x = begin;
			selectionBegin.y = end;
			
			engine.select(begin, end);
			engine.caretIndex = end + 1;
		}
		
		override protected function onMouseUp(event:MouseEvent):void
		{
			super.onMouseUp(event);
			
			selectionBegin.x = 0;
			selectionBegin.y = 0;
		}
		
		override protected function onMouseMove(event:MouseEvent):void
		{
			super.onMouseMove(event);
			
			if(!event.buttonDown)
				return;
			
			var info:EventLineInfo = EventLineInfo.getInfo(event);
			
			if(!info)
				return;
			
			var engine:ITextEngine = info.engine;
			var line:TextLine = info.line;
			var block:TextBlock = line.textBlock;
			var selection:Point = engine.selection.clone();
			var caretIndex:int = engine.caretIndex;
			var blockPosition:int = engine.getBlockPosition(block);
			var blockSize:int = engine.getBlockSize(block);
			
			var begin:int = blockPosition;
			var end:int = blockPosition + blockSize;
			
			if(begin < selectionBegin.x)
			{
				selection.x = begin;
				selection.y = selectionBegin.y;
				caretIndex = begin;
			}
			else if(begin > selectionBegin.y)
			{
				selection.x = selectionBegin.x;
				selection.y = end - 1;
				caretIndex = end;
			}
			else
			{
				selection.x = selectionBegin.x;
				selection.y = selectionBegin.y;
				caretIndex = selectionBegin.y + 1;
			}
			
			engine.select(selection.x, selection.y);
			engine.caretIndex = caretIndex;
		}
	}
}
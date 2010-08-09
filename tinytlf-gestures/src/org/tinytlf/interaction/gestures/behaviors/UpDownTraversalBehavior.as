package org.tinytlf.interaction.gestures.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;

	public class UpDownTraversalBehavior extends Behavior
	{
		override protected function onKeyDown(event:KeyboardEvent):void
		{
			super.onKeyDown(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event);
			
			if(!info)
				return;
			
			var engine:ITextEngine = info.engine;
			var line:TextLine = info.line;
			var block:TextBlock = line.textBlock;
			var caretIndex:int = engine.caretIndex;
			var blockPosition:int = engine.getBlockPosition(block);
			
			var atomBounds:Rectangle;//
			var globalPosition:Point;// = line.localToGlobal(atomBounds.topLeft);
			//  When selecting between lines, try to keep the caret position as 
			//  horizontally consistent as possible.
			if(event.keyCode == Keyboard.UP)
			{
				//  If they press up, check for a previous line. If there isn't 
				//  a line to go to, try to jump to the previous TextBlock. If 
				//  there isn't a TB to go to, set caret index to 0.
				if(line.previousLine)
				{
				}
			}
		}
	}
}
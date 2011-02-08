package org.tinytlf.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.analytics.ITextEngineAnalytics;
	
	public class KeySelectionBehaviorBase extends SelectionBehaviorBase
	{
		public function KeySelectionBehaviorBase()
		{
			super();
		}
		
		[Event("keyDown")]
		override public function downAction():void
		{
			var pt:Point = getSelection();
			
			var k:KeyboardEvent = KeyboardEvent(finalEvent);
			if(k.shiftKey)
				engine.select(pt.x, pt.y);
			else
				engine.select();
			
			var anchor:Point = getAnchor();
			engine.caretIndex = anchor.x;
			
			//assign focus to the proper line
			assignFocus();
		}
		
		override protected function getSelection():Point
		{
			var pt:Point = selection;
			var nextCaret:Point = getAnchor();
			
			if(!validSelection)
				pt = new Point(caret, caret);
			
			if(caret <= pt.x)
				pt.x = nextCaret.x;
			else if(caret > pt.x)
				pt.y = nextCaret.x;
			
			return pt;
		}
		
		protected function assignFocus():void
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var caret:int = engine.caretIndex;
			
			if(caret < 0)
				caret = 0;
			if(caret >= a.contentLength)
				caret = a.contentLength - 1;
			
			var block:TextBlock = a.blockAtContent(caret);
			var blockStart:int = a.blockContentStart(block);
			var newLine:TextLine = block.getTextLineAtCharIndex(caret - blockStart);
			
			if(newLine != line)
			{
				line.stage.focus = container.target;
			}
		}
	}
}
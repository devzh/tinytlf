package org.tinytlf.interaction.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	public class LeftArrowBehavior extends KeySelectionBehaviorBase
	{
		public function LeftArrowBehavior()
		{
			super();
		}
		
		[Event("keyDown")]
		override public function downAction():void
		{
			var pt:Point = engine.selection.clone();
			var caret:int = engine.caretIndex;
			
			if(pt.x != pt.x || pt.y != pt.y)
				pt = new Point(caret, caret);
			
			if(caret <= pt.x)
				--pt.x;
			else if(caret > pt.x)
				--pt.y;
			
			var k:KeyboardEvent = KeyboardEvent(event);
			if(k.shiftKey)
				engine.select(pt.x, pt.y);
			else
				engine.select();
			
			--engine.caretIndex;
		}
	}
}
//012345
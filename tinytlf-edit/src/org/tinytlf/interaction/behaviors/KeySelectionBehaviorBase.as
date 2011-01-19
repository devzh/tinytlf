package org.tinytlf.interaction.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	import org.tinytlf.interaction.behaviors.*;
	
	public class KeySelectionBehaviorBase extends SelectionBehaviorBase
	{
		public function KeySelectionBehaviorBase()
		{
			super();
		}
		
		override public function downAction():void
		{
			anchor = getAnchor();
			
			var selection:Point = getSelection();
			
			engine.select(selection.x, selection.y);
			
			if(anchor.x > selection.x)
				engine.caretIndex = selection.x;
			else if(anchor.x < selection.y)
				engine.caretIndex = selection.y + 1;
			else if(anchor.x == selection.x)
				engine.caretIndex = anchor.x;
			
			var k:KeyboardEvent = KeyboardEvent(event);
			if(!k.shiftKey)
			{
				originalCaret = null;
				engine.select();
			}
		}
		
		protected var originalCaret:Point;
		
		override protected function getAnchor():Point
		{
			if(originalCaret == null)
				originalCaret = new Point(engine.caretIndex, engine.caretIndex);
			
			return originalCaret;
		}
	}
}
package org.tinytlf.interaction.behaviors.selection.keyboard
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	import org.tinytlf.interaction.behaviors.selection.SelectionBehaviorBase;
	
	public class KeyboardSelectionBehavior extends SelectionBehaviorBase
	{
		public function KeyboardSelectionBehavior()
		{
			super();
		}
		
		[Event("keyDown")]
		override public function downAction():void
		{
			super.downAction();
		}
		
		override protected function getAnchor():Point
		{
			var caret:int = engine.caretIndex;
			return new Point(caret, caret);
		}
	}
}
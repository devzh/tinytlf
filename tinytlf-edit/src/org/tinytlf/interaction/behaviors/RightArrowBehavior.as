package org.tinytlf.interaction.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	public class RightArrowBehavior extends KeySelectionBehaviorBase
	{
		public function RightArrowBehavior()
		{
			super();
		}
		
		override protected function getSelection():Point
		{
			var pt:Point = engine.selection.clone();
			var caret:int = engine.caretIndex;
			
			var nextCaret:Point = getAnchor();
			
			if(pt.x != pt.x || pt.y != pt.y)
				pt = new Point(caret, caret);
			
			if(caret <= pt.x)
				pt.x = nextCaret.x;
			else if(caret > pt.x)
				pt.y = nextCaret.x;
			
			return pt;
		}
		
		override protected function getAnchor():Point
		{
			return new Point(engine.caretIndex + 1, 0);
		}
	}
}
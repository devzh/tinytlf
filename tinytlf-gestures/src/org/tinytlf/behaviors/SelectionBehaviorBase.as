package org.tinytlf.behaviors
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	
	public class SelectionBehaviorBase extends MultiGestureBehavior
	{
		public function SelectionBehaviorBase()
		{
			super();
		}
		
		public function downAction():void
		{
			anchor = getAnchor();
			engine.caretIndex = anchor.y;
		}
		
		public function moveAction():void
		{
			var end:Point = getSelection();
			
			if(anchor.x > end.x)
			{
				engine.select(end.x, anchor.y);
				engine.caretIndex = end.x;
			}
			else if(anchor.x < end.x)
			{
				engine.select(anchor.x, end.y);
				engine.caretIndex = end.y;
			}
			else if(anchor.x == end.x)
			{
				engine.select(anchor.x, anchor.y);
				engine.caretIndex = anchor.x;
			}
		}
		
		public function upAction():void
		{
			anchor.x = 0;
			anchor.y = 0;
		}
		
		protected var anchor:Point = new Point();
		
		protected function getAnchor():Point
		{
			return new Point();
		}
		
		protected function getSelection():Point
		{
			return new Point();
		}
	}
}
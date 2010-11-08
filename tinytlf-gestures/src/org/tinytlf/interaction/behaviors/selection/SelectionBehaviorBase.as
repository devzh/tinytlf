package org.tinytlf.interaction.behaviors.selection
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.tinytlf.interaction.behaviors.MultiGestureBehavior;
	
	public class SelectionBehaviorBase extends MultiGestureBehavior
	{
		public function SelectionBehaviorBase()
		{
			super();
		}
		
		public function downAction():void
		{
			engine.select();
			var pt:Point = getAnchor();
			anchor.x = pt.x;
			anchor.y = pt.y;
			engine.caretIndex = anchor.y;
		}
		
		public function moveAction():void
		{
			var end:Point = getSelection();
			
			if(anchor.x > end.x)
				engine.select(end.x, anchor.y);
			else if(anchor.x < end.x)
				engine.select(anchor.x, end.y);
			else if(anchor.x == end.x)
				engine.select(anchor.x, anchor.y);
		}
		
		public function upAction():void
		{
			anchor.x = 0;
			anchor.y = 0;
		}
		
		protected const anchor:Point = new Point();
		
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
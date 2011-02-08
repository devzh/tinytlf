package org.tinytlf.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	import org.tinytlf.util.TinytlfUtil;
	
	public class LeftArrowBehavior extends KeySelectionBehaviorBase
	{
		public function LeftArrowBehavior()
		{
			super();
		}
		
		override protected function getAnchor():Point
		{
			var k:KeyboardEvent = finalEvent as KeyboardEvent;
			if(validSelection && !k.shiftKey)
			{
				if(caret > selection.x)
					return new Point(selection.x, 0);
				
				return new Point(caret, 0);
			}
				
			return new Point(caret - 1, 0);
		}
	}
}
package org.tinytlf.interaction.behaviors
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	import org.tinytlf.util.TinytlfUtil;
	
	public class RightArrowBehavior extends KeySelectionBehaviorBase
	{
		public function RightArrowBehavior()
		{
			super();
		}
		
		override protected function getAnchor():Point
		{
			var k:KeyboardEvent = event as KeyboardEvent;
			if(validSelection && !k.shiftKey)
			{
				if(caret < selection.y)
					return new Point(selection.y, 0);
				
				return new Point(caret, 0);
			}
			
			return new Point(caret + 1, 0);
		}
	}
}
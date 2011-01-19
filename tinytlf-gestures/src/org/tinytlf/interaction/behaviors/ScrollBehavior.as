package org.tinytlf.interaction.behaviors
{
	import flash.events.*;
	
	public class ScrollBehavior extends MultiGestureBehavior
	{
		public function ScrollBehavior()
		{
			super();
		}
		
		[Event("mouseWheel")]
		public function scrollWheel(events:Vector.<Event>):void
		{
			engine.scrollPosition -= (MouseEvent(event).delta * 3);
		}
	}
}
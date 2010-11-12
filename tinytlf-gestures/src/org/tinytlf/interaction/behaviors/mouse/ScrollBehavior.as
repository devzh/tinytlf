package org.tinytlf.interaction.behaviors.mouse
{
	import flash.events.*;
	
	import org.tinytlf.interaction.behaviors.MultiGestureBehavior;
	
	public class ScrollBehavior extends MultiGestureBehavior
	{
		public function ScrollBehavior()
		{
			super();
		}
		
		[Event("mouseWheel")]
		public function scrollWheel(events:Vector.<Event>):void
		{
			var event:MouseEvent = MouseEvent(events[events.length - 1]);
			engine.scrollPosition -= (event.delta * 3);
		}
	}
}
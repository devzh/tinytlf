package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
	[Event(KeyboardEvent.KEY_DOWN)]
	
	public class RightArrowGesture extends Gesture
	{
		public function RightArrowGesture(target:IEventDispatcher=null)
		{
			super(target);
			hsm.appendChild(<right/>);
		}
		
		public function right(event:KeyboardEvent):Boolean
		{
			return event.keyCode == Keyboard.RIGHT;
		}
	}
}
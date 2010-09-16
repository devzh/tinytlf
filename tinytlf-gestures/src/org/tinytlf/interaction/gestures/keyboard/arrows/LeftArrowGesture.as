package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
	[Event("keyDown")]
	
	public class LeftArrowGesture extends Gesture
	{
		public function LeftArrowGesture(target:IEventDispatcher=null)
		{
			super(target);
			hsm.appendChild(<left/>);
		}
		
		public function left(event:KeyboardEvent):Boolean
		{
			return (event.keyCode === Keyboard.LEFT);
		}
	}
}
package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
	[Event("keyDown")]
	
	public class DownArrowGesture extends Gesture
	{
		public function DownArrowGesture(target:IEventDispatcher=null)
		{
			super(target);
			hsm.appendChild(<down/>);
		}
		
		public function down(event:KeyboardEvent):Boolean
		{
			return (event.keyCode === Keyboard.DOWN);
		}
	}
}
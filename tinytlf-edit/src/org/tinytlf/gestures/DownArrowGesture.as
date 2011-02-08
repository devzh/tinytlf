package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	[Event("keyDown")]
	
	public class DownArrowGesture extends Gesture
	{
		public function DownArrowGesture()
		{
			super();
			
			hsm.appendChild(<down/>);
		}
		
		public function down(event:KeyboardEvent):Boolean
		{
			return (event.keyCode === Keyboard.DOWN);
		}
	}
}
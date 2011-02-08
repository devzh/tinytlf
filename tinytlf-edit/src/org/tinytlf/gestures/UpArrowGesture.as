package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	
	[Event("keyDown")]
	
	public class UpArrowGesture extends Gesture
	{
		public function UpArrowGesture()
		{
			super();
			
			hsm.appendChild(<up/>);
		}
		
		public function up(event:KeyboardEvent):Boolean
		{
			return (event.keyCode === Keyboard.UP);
		}
	}
}
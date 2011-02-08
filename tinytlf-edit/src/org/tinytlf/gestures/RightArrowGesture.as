package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	
	[Event("keyDown")]
	
	public class RightArrowGesture extends Gesture
	{
		public function RightArrowGesture()
		{
			super();
			
			hsm.appendChild(<right/>);
			hsm.appendChild(<shift><right/></shift>);
		}
		
		public function shift(event:KeyboardEvent):Boolean
		{
			return (event.keyCode == Keyboard.SHIFT && event.shiftKey);
		}
		
		public function right(event:KeyboardEvent):Boolean
		{
			return (event.keyCode === Keyboard.RIGHT);
		}
	}
}
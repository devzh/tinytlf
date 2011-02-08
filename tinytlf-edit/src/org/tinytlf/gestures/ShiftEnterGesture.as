package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	[Event("keyDown")]
	public class ShiftEnterGesture extends Gesture
	{
		public function ShiftEnterGesture()
		{
			super();
			
			hsm.appendChild(<enter/>);
		}
		
		public function enter(event:KeyboardEvent):Boolean
		{
			return (event.keyCode == Keyboard.ENTER && event.shiftKey);
		}
	}
}
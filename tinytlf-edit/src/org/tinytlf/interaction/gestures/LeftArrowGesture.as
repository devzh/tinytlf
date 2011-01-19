package org.tinytlf.interaction.gestures
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	[Event("keyDown")]
	public class LeftArrowGesture extends Gesture
	{
		public function LeftArrowGesture()
		{
			super();
			
			hsm.appendChild(<left/>);
			hsm.appendChild(<shift><left/></shift>);
		}
		
		public function shift(event:KeyboardEvent):Boolean
		{
			return (event.keyCode == Keyboard.SHIFT && event.shiftKey);
		}
		
		public function left(event:KeyboardEvent):Boolean
		{
			return (event.keyCode === Keyboard.LEFT);
		}
	}
}
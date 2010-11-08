package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
	[Event("keyDown")]
	
	public class RightArrowGesture extends Gesture
	{
		public function RightArrowGesture()
		{
			super();
			
			hsm.appendChild(<right/>);
		}
		
		public function right(event:KeyboardEvent):Boolean
		{
			return (event.keyCode === Keyboard.RIGHT);
		}
	}
}
package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
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
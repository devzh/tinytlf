package org.tinytlf.interaction.gestures.mouse
{
	import flash.events.MouseEvent;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
	[Event("mouseWheel")]
	public class MouseWheelGesture extends Gesture
	{
		public function MouseWheelGesture()
		{
			super();
			hsm.appendChild(<wheel/>)
		}
		
		public function wheel(event:MouseEvent):Boolean
		{
			return event.type == MouseEvent.MOUSE_WHEEL;
		}
	}
}
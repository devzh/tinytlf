package org.tinytlf.interaction.gestures
{
	import flash.events.MouseEvent;
	
	
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
package org.tinytlf.gestures
{
	import flash.events.MouseEvent;
	
	
	[Event("rollOut")]
	
	public class MouseOutGesture extends Gesture
	{
		public function MouseOutGesture()
		{
			super();
			
			hsm.appendChild(<out/>);
		}
		
		public function out(event:MouseEvent):Boolean
		{
			return event.type == MouseEvent.ROLL_OUT;
		}
	}
}
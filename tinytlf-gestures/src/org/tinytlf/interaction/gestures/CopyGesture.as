package org.tinytlf.interaction.gestures
{
	import flash.events.Event;
	
	
	[Event("copy")]
	
	public class CopyGesture extends Gesture
	{
		public function CopyGesture()
		{
			super();
			
			hsm.appendChild(<copy/>);
		}
		
		public function copy(event:Event):Boolean
		{
			return (event.type === Event.COPY);
		}
	}
}
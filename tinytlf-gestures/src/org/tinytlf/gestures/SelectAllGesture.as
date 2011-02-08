package org.tinytlf.gestures
{
	import flash.events.Event;
	
	
	[Event("selectAll")]
	public class SelectAllGesture extends Gesture
	{
		public function SelectAllGesture()
		{
			super();
			
			hsm.appendChild(<select/>);
		}
		
		public function select(event:Event):Boolean
		{
			return (event.type === Event.SELECT_ALL);
		}
	}
}
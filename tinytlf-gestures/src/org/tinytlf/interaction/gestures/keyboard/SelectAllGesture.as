package org.tinytlf.interaction.gestures.keyboard
{
	import flash.events.Event;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
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
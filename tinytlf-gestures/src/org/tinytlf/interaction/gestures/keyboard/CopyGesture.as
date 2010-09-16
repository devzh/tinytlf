package org.tinytlf.interaction.gestures.keyboard
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
	[Event("copy")]
	
	public class CopyGesture extends Gesture
	{
		public function CopyGesture(target:IEventDispatcher=null)
		{
			super(target);
			
			hsm.appendChild(<copy/>);
		}
		
		public function copy(event:Event):Boolean
		{
			return (event.type === Event.COPY);
		}
	}
}
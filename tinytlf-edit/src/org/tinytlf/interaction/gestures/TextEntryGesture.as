package org.tinytlf.interaction.gestures
{
	import flash.events.KeyboardEvent;

	[Event("keyDown")]
	public class TextEntryGesture extends Gesture
	{
		public function TextEntryGesture()
		{
			super();
			
			hsm.appendChild(<down/>);
		}
		
		public function down(event:KeyboardEvent):Boolean
		{
			var char:String = String.fromCharCode(event.charCode);
			return char != '' && event.charCode;
		}
	}
}
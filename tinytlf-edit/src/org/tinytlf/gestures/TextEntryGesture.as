package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

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
			var result:Boolean = char != '' && event.charCode;
			result &&= !(event.keyCode == Keyboard.ENTER && event.shiftKey);
			result &&= !event.ctrlKey;
			result &&= !(event.keyCode == Keyboard.DELETE);
			result &&= !(event.keyCode == Keyboard.BACKSPACE);
			
			return result;
		}
	}
}
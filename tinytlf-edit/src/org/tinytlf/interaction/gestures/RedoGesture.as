package org.tinytlf.interaction.gestures
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.TinytlfUtil;

	[Event("keyDown")]
	public class RedoGesture extends Gesture
	{
		public function RedoGesture()
		{
			super();
			
			hsm.appendChild(<redo/>);
		}
		
		public function redo(event:KeyboardEvent):Boolean
		{
			var char:String = String.fromCharCode(event.charCode);
			
			if(TinytlfUtil.isMac())
				return char === 'z' && event.shiftKey && event.ctrlKey;
			
			return char === 'y' && event.ctrlKey;
		}
	}
}
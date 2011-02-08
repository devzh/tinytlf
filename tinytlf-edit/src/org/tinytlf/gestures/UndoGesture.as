package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.TinytlfUtil;

	[Event("keyDown")]
	public class UndoGesture extends Gesture
	{
		public function UndoGesture()
		{
			super();
			
			hsm.appendChild(<undo/>);
		}
		
		public function undo(event:KeyboardEvent):Boolean
		{
			var result:Boolean = event.ctrlKey && (event.charCode == 122); //small 'z'
			
			if(TinytlfUtil.isMac())
				result &&= !event.shiftKey;
			
			return result;
		}
	}
}
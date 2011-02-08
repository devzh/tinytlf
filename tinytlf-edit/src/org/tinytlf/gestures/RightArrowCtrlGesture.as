package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.TinytlfUtil;
	
	[Event("keyDown")]
	
	public class RightArrowCtrlGesture extends RightArrowGesture
	{
		override public function right(event:KeyboardEvent):Boolean
		{
			return super.right(event) && (TinytlfUtil.isMac() ? event.altKey : event.ctrlKey);
		}
	}
}
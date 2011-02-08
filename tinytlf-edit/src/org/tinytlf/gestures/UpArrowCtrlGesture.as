package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.TinytlfUtil;
	
	[Event("keyDown")]
	
	public class UpArrowCtrlGesture extends UpArrowGesture
	{
		override public function up(event:KeyboardEvent):Boolean
		{
			return super.up(event) && (TinytlfUtil.isMac() ? event.altKey : event.ctrlKey);
		}
	}
}
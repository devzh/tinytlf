package org.tinytlf.interaction.gestures
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.TinytlfUtil;
	
	[Event("keyDown")]
	
	public class LeftArrowCtrlGesture extends LeftArrowGesture
	{
		override public function left(event:KeyboardEvent):Boolean
		{
			return super.left(event) && (TinytlfUtil.isMac() ? event.altKey : event.ctrlKey);
		}
	}
}
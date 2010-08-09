package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.FTEUtil;
	
	[Event("keyDown")]
	
	public class RightArrowCtrlGesture extends RightArrowGesture
	{
		override public function right(event:KeyboardEvent):Boolean
		{
			return super.right(event) && FTEUtil.isMac() ? event.altKey : event.ctrlKey;
		}
	}
}
package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.FTEUtil;
	
	[Event("keyDown")]
	
	public class DownArrowCtrlGesture extends DownArrowGesture
	{
		override public function down(event:KeyboardEvent):Boolean
		{
			return super.down(event) && FTEUtil.isMac() ? event.altKey : event.ctrlKey;
		}
	}
}
package org.tinytlf.interaction.gestures.keyboard.arrows
{
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.util.FTEUtil;
	
	[Event("keyDown")]
	
	public class UpArrowCtrlGesture extends UpArrowGesture
	{
		override public function up(event:KeyboardEvent):Boolean
		{
			return super.up(event) && FTEUtil.isMac() ? event.altKey : event.ctrlKey;
		}
	}
}
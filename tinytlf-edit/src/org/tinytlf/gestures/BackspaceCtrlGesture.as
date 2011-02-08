package org.tinytlf.gestures
{
    import flash.events.KeyboardEvent;
    
    import org.tinytlf.util.TinytlfUtil;

    [Event("keyDown")]

    public class BackspaceCtrlGesture extends BackspaceGesture
    {
        override public function backspace(event:KeyboardEvent):Boolean
        {
			var ctrlKey:Boolean = TinytlfUtil.isMac() ? event.altKey : event.ctrlKey;
            return super.backspace(event) && ctrlKey;
        }
    }
}
package org.tinytlf.interaction.gestures.keyboard
{
    import flash.events.KeyboardEvent;

    [Event("keyDown")]

    public class BackspaceCtrlGesture extends BackspaceGesture
    {
        override public function backspace(event:KeyboardEvent):Boolean
        {
            return super.backspace(event) && event.ctrlKey;
        }
    }
}
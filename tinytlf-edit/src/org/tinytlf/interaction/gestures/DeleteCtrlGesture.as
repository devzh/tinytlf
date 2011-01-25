package org.tinytlf.interaction.gestures
{
    import flash.events.KeyboardEvent;

    [Event("keyDown")]
    public class DeleteCtrlGesture extends DeleteGesture
    {
        override public function deleteKey(event:KeyboardEvent):Boolean
        {
            return super.deleteKey(event) && event.ctrlKey;
        }
    }
}
package org.tinytlf.interaction.gestures
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    

    [Event("keyDown")]

    public class DeleteGesture extends Gesture
    {
        public function DeleteGesture()
        {
			super();
			
            hsm.appendChild(<deleteKey/>);
        }

        public function deleteKey(event:KeyboardEvent):Boolean
        {
            return event.keyCode == Keyboard.DELETE;
        }
    }
}
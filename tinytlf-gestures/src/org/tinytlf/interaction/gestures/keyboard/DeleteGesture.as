package org.tinytlf.interaction.gestures.keyboard
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    import org.tinytlf.interaction.gestures.Gesture;

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
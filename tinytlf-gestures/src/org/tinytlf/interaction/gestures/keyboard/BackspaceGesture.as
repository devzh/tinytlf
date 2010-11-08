package org.tinytlf.interaction.gestures.keyboard
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    import org.tinytlf.interaction.gestures.Gesture;

    [Event("keyDown")]

    public class BackspaceGesture extends Gesture
    {
        public function BackspaceGesture()
        {
			super();
			
            hsm.appendChild(<backspace/>);
        }

        public function backspace(event:KeyboardEvent):Boolean
        {
            return event.keyCode == Keyboard.BACKSPACE;
        }
    }
}